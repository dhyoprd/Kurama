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
    @Published var intensity: Intensity = .normal
    @Published var todaysQuests: [DailyQuestVM] = []
    @Published var level = 1
    @Published var xp = 0
    @Published var rankCode = "E"
    @Published var stats: [String: Int] = [:]
    @Published var rewardFlash: String?
    
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
        let intensity: String
        let level: Int
        let xp: Int
        let rank: String
        let strength: Int
        let intelligence: Int
        let discipline: Int
        let charisma: Int
        let wealth: Int
        let mind: Int
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
                .select("id,avatar_url,life_class,intensity,level,xp,rank,strength,intelligence,discipline,charisma,wealth,mind")
                .eq("id", value: uid.uuidString)
                .execute()
                .value
            let row = rows.first
            await MainActor.run {
                self.hasProfile = row != nil
                self.needsAvatar = row != nil && row?.avatar_url == nil
                self.lifeClass = row.flatMap { LifeClass(rawValue: $0.life_class) }
                self.intensity = row.flatMap { Intensity(rawValue: $0.intensity) } ?? .normal
                self.avatarURL = row?.avatar_url.flatMap { URL(string: $0) }
                self.level = row?.level ?? 1
                self.xp = row?.xp ?? 0
                self.rankCode = row?.rank ?? "E"
                self.stats = row.map {
                    ["strength": $0.strength, "intelligence": $0.intelligence,
                     "discipline": $0.discipline, "charisma": $0.charisma,
                     "wealth": $0.wealth, "mind": $0.mind]
                } ?? [:]
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

    // MARK: - Daily quests (#6)

    struct DailyQuestVM: Identifiable, Equatable {
        let id: UUID
        let title: String
        let difficulty: String
        let statReward: String
        let status: String
    }

    private struct QuestPoolRow: Decodable {
        let id: UUID
        let difficulty: String
        let life_class: String?
    }
    private struct QuestTitleRow: Decodable {
        let title: String
        let difficulty: String
        let stat_reward: String
    }
    private struct TodayQuestRow: Decodable {
        let id: UUID
        let status: String
        let custom_title: String?
        let quests: QuestTitleRow?
    }
    private struct UserQuestInsert: Encodable {
        let user_id: String
        let quest_id: String
        let assigned_date: String
        let status: String
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Loads today's quests; assigns 3 (idempotent per day) if none exist yet.
    func loadOrAssignTodaysQuests() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let today = Self.dayFormatter.string(from: Date())
        do {
            var rows = try await fetchTodayQuests(client, uid: uid, today: today)
            if rows.isEmpty {
                try await assignTodayQuests(client, uid: uid, today: today)
                rows = try await fetchTodayQuests(client, uid: uid, today: today)
            }
            let vms = rows.map {
                DailyQuestVM(
                    id: $0.id,
                    title: $0.quests?.title ?? $0.custom_title ?? "Quest",
                    difficulty: $0.quests?.difficulty ?? "E",
                    statReward: $0.quests?.stat_reward ?? "discipline",
                    status: $0.status
                )
            }
            await MainActor.run { self.todaysQuests = vms }
        } catch {
            await MainActor.run { self.todaysQuests = [] }
        }
    }

    private func fetchTodayQuests(_ client: SupabaseClient, uid: UUID, today: String) async throws -> [TodayQuestRow] {
        try await client
            .from("user_quests")
            .select("id,status,custom_title,quests(title,difficulty,stat_reward)")
            .eq("user_id", value: uid.uuidString)
            .eq("assigned_date", value: today)
            .execute()
            .value
    }

    private func assignTodayQuests(_ client: SupabaseClient, uid: UUID, today: String) async throws {
        let poolRows: [QuestPoolRow] = try await client
            .from("quests").select("id,difficulty,life_class").execute().value
        let pool: [Quest] = poolRows.compactMap { row in
            guard let diff = Difficulty(rawValue: row.difficulty) else { return nil }
            return Quest(
                id: row.id.uuidString,
                lifeClass: row.life_class.flatMap { LifeClass(rawValue: $0) },
                difficulty: diff
            )
        }
        var rng = SeededRandomNumberGenerator(seed: Self.seed(uid: uid, day: today))
        let chosen = DailyQuestAssigner.assign(
            lifeClass: lifeClass ?? .warrior,
            intensity: intensity,
            alreadyAssignedToday: false,
            pool: pool,
            using: &rng
        )
        guard !chosen.isEmpty else { return }
        let inserts = chosen.map {
            UserQuestInsert(user_id: uid.uuidString, quest_id: $0.id, assigned_date: today, status: "active")
        }
        try await client.from("user_quests").insert(inserts).execute()
    }

    private static func seed(uid: UUID, day: String) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in (uid.uuidString + day).utf8 {
            hash = (hash ^ UInt64(byte)) &* 1099511628211
        }
        return hash
    }

    // MARK: - Quest completion (#7)

    private struct UQComplete: Encodable {
        let status: String
        let xp_earned: Int
        let stat_earned: String
        let completed_at: String
    }
    private struct IDRow: Decodable { let id: UUID }

    /// Complete a quest: award XP/stat via the cores, persist, prevent double-claim.
    func completeQuest(id: UUID, difficulty: String, statReward: String) async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        guard let diff = Difficulty(rawValue: difficulty) else { return }
        let reward = QuestRewardCalculator.reward(difficulty: diff, proofAttached: false)
        do {
            // Claim only if still active (atomic guard against double XP).
            let claimed: [IDRow] = try await client
                .from("user_quests")
                .update(UQComplete(
                    status: "completed",
                    xp_earned: reward.xp,
                    stat_earned: statReward,
                    completed_at: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("id", value: id.uuidString)
                .eq("status", value: "active")
                .select("id")
                .execute()
                .value
            guard !claimed.isEmpty else { return }

            let current = ProgressionState(xp: xp, level: level, rank: Rank(rawValue: rankCode) ?? .e)
            let result = ProgressionEngine.apply(current, xpGain: reward.xp)
            let newStat = (stats[statReward] ?? 10) + reward.statDelta

            try await client.from("profiles")
                .update(["xp": result.state.xp, "level": result.state.level, statReward: newStat])
                .eq("id", value: uid.uuidString).execute()
            try await client.from("profiles")
                .update(["rank": result.state.rank.rawValue])
                .eq("id", value: uid.uuidString).execute()

            let leveled = result.events.contains { if case .leveledUp = $0 { return true } else { return false } }
            let ranked = result.events.contains { if case .rankedUp = $0 { return true } else { return false } }
            let flash = ranked ? "RANK UP \(result.state.rank.rawValue)!  +\(reward.xp) XP"
                : (leveled ? "LEVEL \(result.state.level)!  +\(reward.xp) XP" : "+\(reward.xp) XP")

            await loadProfileStatus()
            await loadOrAssignTodaysQuests()
            await MainActor.run { self.rewardFlash = flash }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { self.rewardFlash = nil }
        } catch {
            // Leave UI as-is on failure.
        }
    }
}
