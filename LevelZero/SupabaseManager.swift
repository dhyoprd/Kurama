import Foundation
import Supabase
import LevelZeroCore

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient?
    @Published var isConnected = false
    @Published var connectionMessage = "Not checked"
    @Published var isChecking = false
    @Published var isAuthenticated = false
    @Published var hasProfile = false
    @Published var needsAvatar = false
    @Published var lifeClass: LifeClass?
    @Published var avatarURL: URL?
    
    private init() {
        if let url = Config.supabaseURL, let key = Config.supabaseAnonKey, !key.isEmpty, !key.contains("your-anon-public-key") {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        } else {
            self.client = nil
        }
    }
    
    func checkConnection() async {
        guard let client = client else {
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionMessage = "Supabase configuration missing or using templates. Please update SupabaseConfig.plist."
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isChecking = true
        }
        
        do {
            // A simple query to check connectivity. We can check auth session which requires internet connectivity.
            _ = try await client.auth.session
            DispatchQueue.main.async {
                self.isConnected = true
                self.connectionMessage = "Supabase Connection Success!"
                self.isChecking = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isConnected = false
                // If the error is just an unauthenticated session, it actually means connection succeeded because the server responded!
                // So if we get a response from Supabase (even an auth error, but not network error), it is a successful connectivity check.
                if error.localizedDescription.lowercased().contains("network") || error.localizedDescription.lowercased().contains("connection") {
                    self.connectionMessage = "Connection Failed: \(error.localizedDescription)"
                } else {
                    self.isConnected = true
                    self.connectionMessage = "Supabase Connection Success! (Auth check responded)"
                }
                self.isChecking = false
            }
        }
    }

    // MARK: - Auth (#3)

    enum AuthError: Error { case notConfigured }

    /// Observe Supabase auth state -> drives routing.
    func observeAuth() {
        guard let client else { return }
        Task {
            for await (_, session) in client.auth.authStateChanges {
                let authed = session != nil
                await MainActor.run { self.isAuthenticated = authed }
                if authed {
                    await loadProfileStatus()
                } else {
                    await MainActor.run { self.hasProfile = false }
                }
            }
        }
    }

    /// Refresh the persisted session on launch.
    func refreshSession() async {
        guard let client else { return }
        let session = try? await client.auth.session
        await MainActor.run { self.isAuthenticated = session != nil }
    }

    /// Returns true if signed up AND logged in; false if email confirmation is required.
    @discardableResult
    func signUp(email: String, password: String) async throws -> Bool {
        guard let client else { throw AuthError.notConfigured }
        let response = try await client.auth.signUp(email: email, password: password)
        switch response {
        case .session: return true
        case .user: return false
        }
    }

    func signIn(email: String, password: String) async throws {
        guard let client else { throw AuthError.notConfigured }
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        guard let client else { throw AuthError.notConfigured }
        try await client.auth.signOut()
    }

    // MARK: - Profile (#4)

    private struct ProfileStatusRow: Decodable {
        let id: UUID
        let avatar_url: String?
        let life_class: String
    }

    private struct ProfileInsert: Encodable {
        let id: String
        let username: String
        let life_class: String
        let intensity: String
        let main_goals: [String]
        let height: Double
        let weight: Double
    }

    /// Loads profile existence + avatar status -> drives routing (onboarding / avatar / dashboard).
    func loadProfileStatus() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else {
            await MainActor.run { self.hasProfile = false; self.needsAvatar = false }
            return
        }
        do {
            let rows: [ProfileStatusRow] = try await client
                .from("profiles")
                .select("id,avatar_url,life_class")
                .eq("id", value: uid.uuidString)
                .execute()
                .value
            let row = rows.first
            await MainActor.run {
                self.hasProfile = row != nil
                self.needsAvatar = row != nil && row?.avatar_url == nil
                self.lifeClass = row.flatMap { LifeClass(rawValue: $0.life_class) }
                self.avatarURL = row?.avatar_url.flatMap { URL(string: $0) }
            }
        } catch {
            await MainActor.run { self.hasProfile = false; self.needsAvatar = false }
        }
    }

    /// Insert the profile row from a validated onboarding draft.
    func createProfile(from draft: OnboardingDraft) async throws {
        guard let client else { throw AuthError.notConfigured }
        let uid = try await client.auth.session.user.id
        let payload = ProfileInsert(
            id: uid.uuidString,
            username: draft.characterName.trimmingCharacters(in: .whitespacesAndNewlines),
            life_class: draft.lifeClass?.dbValue ?? "warrior",
            intensity: draft.intensity.dbValue,
            main_goals: draft.goals.map(\.dbValue),
            height: draft.heightCm ?? 0,
            weight: draft.weightKg ?? 0
        )
        try await client.from("profiles").insert(payload).execute()
        await MainActor.run {
            self.hasProfile = true
            self.needsAvatar = true
            self.lifeClass = draft.lifeClass
        }
    }

    // MARK: - Avatar (#5)

    func uploadSelfie(_ data: Data) async throws {
        guard let client else { throw AuthError.notConfigured }
        let uid = try await client.auth.session.user.id
        let path = "\(uid.uuidString).jpg"
        try await client.storage.from("selfies").upload(
            path, data: data,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )
        try await client.from("profiles")
            .update(["original_selfie_url": path])
            .eq("id", value: uid.uuidString)
            .execute()
    }

    /// Invoke the generate-avatar Edge Function, then refresh (avatar_url -> needsAvatar false).
    func generateAvatar(prompt: String) async throws {
        guard let client else { throw AuthError.notConfigured }
        struct Body: Encodable { let prompt: String }
        try await client.functions.invoke(
            "generate-avatar",
            options: FunctionInvokeOptions(body: Body(prompt: prompt))
        )
        await loadProfileStatus()
    }

    /// Proceed without an avatar (failure path must not block the app).
    func skipAvatar() {
        Task { @MainActor in self.needsAvatar = false }
    }
}
