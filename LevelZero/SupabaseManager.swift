import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient?
    @Published var isConnected = false
    @Published var connectionMessage = "Not checked"
    @Published var isChecking = false
    @Published var isAuthenticated = false
    
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
                await MainActor.run { self.isAuthenticated = session != nil }
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
}
