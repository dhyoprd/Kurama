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
    @Published var username = "Hunter"
    @Published var stats: [String: Int] = [:]
    @Published var rewardFlash: String?
    @Published var boss: BossVM?
    @Published var books: [BookVM] = []
    @Published var streak = 0
    @Published var needsRecovery = false
    @Published var lastActiveAt: Date?
    @Published var trophies: [TrophyVM] = []
    
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
        let username: String
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
        let last_active_at: String?
        let current_streak: Int
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
                .select("id,username,avatar_url,life_class,intensity,level,xp,rank,strength,intelligence,discipline,charisma,wealth,mind,last_active_at,current_streak")
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
                self.streak = row?.current_streak ?? 0
                self.username = row?.username ?? "Hunter"
                self.lastActiveAt = row?.last_active_at.flatMap { Self.parseTimestamp($0) }
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

    /// Regenerate the avatar to its evolved form for the current rank + top stat (#20).
    func regenerateAvatarForCurrentRank() async {
        let s = Stats(
            strength: stats["strength"] ?? 10, intelligence: stats["intelligence"] ?? 10,
            discipline: stats["discipline"] ?? 10, charisma: stats["charisma"] ?? 10,
            wealth: stats["wealth"] ?? 10, mind: stats["mind"] ?? 10
        )
        let top = AvatarPromptSelector.topStat(of: s)
        let rank = Rank(rawValue: rankCode) ?? .e
        try? await generateAvatar(prompt: AvatarPromptSelector.prompt(rank: rank, topStat: top))
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
        let custom_difficulty: String?
        let custom_stat_reward: String?
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
                    difficulty: $0.quests?.difficulty ?? $0.custom_difficulty ?? "E",
                    statReward: $0.quests?.stat_reward ?? $0.custom_stat_reward ?? "discipline",
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
            .select("id,status,custom_title,custom_difficulty,custom_stat_reward,quests(title,difficulty,stat_reward)")
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
    func completeQuest(id: UUID, difficulty: String, statReward: String, proofAttached: Bool = false) async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        guard let diff = Difficulty(rawValue: difficulty) else { return }
        let reward = QuestRewardCalculator.reward(difficulty: diff, proofAttached: proofAttached)
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
            if ranked {
                Task { await self.regenerateAvatarForCurrentRank() }
                NotificationManager.shared.notifyRankUp(rankCode)
            }
            await MainActor.run { self.rewardFlash = flash }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { self.rewardFlash = nil }
        } catch {
            // Leave UI as-is on failure.
        }
    }

    /// Skip an active quest with a reason (no XP awarded).
    func skipQuest(id: UUID, reason: String) async {
        guard let client else { return }
        do {
            try await client.from("user_quests")
                .update(["status": "skipped", "skip_reason": reason])
                .eq("id", value: id.uuidString)
                .eq("status", value: "active")
                .execute()
            await loadOrAssignTodaysQuests()
        } catch {}
    }

    /// Upload a photo proof for a quest, then complete it with the +20 XP bonus.
    func completeQuestWithProof(id: UUID, difficulty: String, statReward: String, imageData: Data) async {
        guard let client else { return }
        guard imageData.count <= 5_000_000 else {
            await MainActor.run { self.rewardFlash = "Proof too large (max 5MB)" }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run { self.rewardFlash = nil }
            return
        }
        struct ProofInsert: Encodable { let user_quest_id: String; let proof_type: String; let proof_url: String }
        let path = "\(id.uuidString).jpg"
        do {
            try await client.storage.from("proofs").upload(
                path, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
            try await client.from("proof_submissions").insert(ProofInsert(
                user_quest_id: id.uuidString, proof_type: "photo", proof_url: path
            )).execute()
            await completeQuest(id: id, difficulty: difficulty, statReward: statReward, proofAttached: true)
        } catch {}
    }

    /// Create a user-authored quest for today; completes via the same reward path.
    func createCustomQuest(title: String, difficulty: Difficulty, statReward: String) async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        struct CustomInsert: Encodable {
            let user_id: String
            let custom_title: String
            let custom_difficulty: String
            let custom_stat_reward: String
            let assigned_date: String
            let status: String
        }
        let today = Self.dayFormatter.string(from: Date())
        do {
            try await client.from("user_quests").insert(CustomInsert(
                user_id: uid.uuidString, custom_title: title,
                custom_difficulty: difficulty.rawValue, custom_stat_reward: statReward,
                assigned_date: today, status: "active"
            )).execute()
            await loadOrAssignTodaysQuests()
        } catch {}
    }

    // MARK: - Weekly boss (#12)

    struct BossVM: Equatable {
        let rowId: UUID
        let currentBossId: UUID
        let title: String
        let description: String
        let progress: Int
        let required: Int
        let status: String
        let badge: String?
        let xpReward: Int
        let statRewards: [String: Int]
        let deadline: Date
        let weekStart: Date
        let rerollsUsed: Int
    }

    private struct BossMaster: Decodable {
        let id: UUID
        let life_class: String?
    }
    private struct BossEmbed: Decodable {
        let title: String
        let description: String
        let required_count: Int
        let xp_reward: Int
        let stat_rewards: [String: Int]
        let badge_reward: String?
    }
    private struct BossJoin: Decodable {
        let id: UUID
        let boss_id: UUID
        let status: String
        let progress: Int
        let rerolls_used: Int
        let week_start_date: String
        let weekly_bosses: BossEmbed?
    }
    private struct BossInsert: Encodable {
        let user_id: String
        let boss_id: String
        let week_start_date: String
        let status: String
    }

    private func currentWeekStart() -> Date {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = .current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return cal.date(from: comps) ?? Date()
    }

    func loadOrSpawnWeeklyBoss() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let weekStart = currentWeekStart()
        let weekStartStr = Self.dayFormatter.string(from: weekStart)
        do {
            var rows = try await fetchBoss(client, uid: uid, week: weekStartStr)
            if rows.isEmpty {
                try await spawnBoss(client, uid: uid, week: weekStartStr)
                rows = try await fetchBoss(client, uid: uid, week: weekStartStr)
            }
            guard let row = rows.first, let m = row.weekly_bosses else {
                await MainActor.run { self.boss = nil }
                return
            }
            let deadline = weekStart.addingTimeInterval(7 * 24 * 3600)
            var status = row.status
            if status == "active" && Date() >= deadline {
                try await client.from("user_weekly_bosses")
                    .update(["status": "failed"]).eq("id", value: row.id.uuidString).execute()
                status = "failed"
            }
            let vm = BossVM(
                rowId: row.id, currentBossId: row.boss_id, title: m.title, description: m.description,
                progress: row.progress, required: m.required_count, status: status,
                badge: m.badge_reward, xpReward: m.xp_reward, statRewards: m.stat_rewards,
                deadline: deadline, weekStart: weekStart, rerollsUsed: row.rerolls_used
            )
            await MainActor.run { self.boss = vm }
        } catch {
            await MainActor.run { self.boss = nil }
        }
    }

    private func fetchBoss(_ client: SupabaseClient, uid: UUID, week: String) async throws -> [BossJoin] {
        try await client.from("user_weekly_bosses")
            .select("id,boss_id,status,progress,rerolls_used,week_start_date,weekly_bosses(title,description,required_count,xp_reward,stat_rewards,badge_reward)")
            .eq("user_id", value: uid.uuidString)
            .eq("week_start_date", value: week)
            .execute().value
    }

    private func spawnBoss(_ client: SupabaseClient, uid: UUID, week: String) async throws {
        let pool: [BossMaster] = try await client.from("weekly_bosses")
            .select("id,life_class").execute().value
        let myClass = lifeClass?.rawValue
        let matched = pool.filter { $0.life_class == myClass }
        let general = pool.filter { $0.life_class == nil }
        guard let chosen = (matched.isEmpty ? general : matched).first else { return }
        try await client.from("user_weekly_bosses").insert(BossInsert(
            user_id: uid.uuidString, boss_id: chosen.id.uuidString, week_start_date: week, status: "active"
        )).execute()
    }

    /// Check off one boss requirement (HP bar depletes).
    func bossAttack() async {
        guard let client, let b = boss, b.status == "active", b.progress < b.required else { return }
        do {
            try await client.from("user_weekly_bosses")
                .update(["progress": b.progress + 1])
                .eq("id", value: b.rowId.uuidString)
                .eq("status", value: "active")
                .execute()
            await loadOrSpawnWeeklyBoss()
        } catch {}
    }

    /// Conquer the boss once all requirements are met (reward via the cores; no double-claim).
    func conquerBoss() async {
        guard let client, let b = boss, b.status == "active", b.progress >= b.required else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let state = BossState(status: .active, weekStart: currentWeekStart(), rerollsUsed: 0)
        let (out, reward) = WeeklyBossLifecycle.conquer(state, now: Date())
        guard out.status == .completed, let reward else { return }
        do {
            let claimed: [IDRow] = try await client.from("user_weekly_bosses")
                .update(["status": "completed", "completed_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: b.rowId.uuidString)
                .eq("status", value: "active")
                .select("id")
                .execute().value
            guard !claimed.isEmpty else { return }

            let cur = ProgressionState(xp: xp, level: level, rank: Rank(rawValue: rankCode) ?? .e)
            let res = ProgressionEngine.apply(cur, xpGain: reward.xp)
            var update: [String: Int] = ["xp": res.state.xp, "level": res.state.level]
            for (stat, delta) in b.statRewards {
                update[stat] = (stats[stat] ?? 10) + delta
            }
            try await client.from("profiles").update(update).eq("id", value: uid.uuidString).execute()
            try await client.from("profiles").update(["rank": res.state.rank.rawValue]).eq("id", value: uid.uuidString).execute()

            let bossRanked = res.events.contains { if case .rankedUp = $0 { return true } else { return false } }
            await loadProfileStatus()
            await loadOrSpawnWeeklyBoss()
            if bossRanked {
                Task { await self.regenerateAvatarForCurrentRank() }
                NotificationManager.shared.notifyRankUp(rankCode)
            }
            await MainActor.run { self.rewardFlash = "BOSS DEFEATED!  +\(reward.xp) XP" }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { self.rewardFlash = nil }
        } catch {}
    }

    /// Reroll the weekly boss (<= once, before Wednesday) into a different matched boss; resets progress.
    func rerollBoss() async {
        guard let client, let b = boss, b.status == "active" else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        _ = uid
        let state = BossState(status: .active, weekStart: b.weekStart, rerollsUsed: b.rerollsUsed)
        guard WeeklyBossLifecycle.canReroll(state, now: Date()) else { return }
        do {
            let pool: [BossMaster] = try await client.from("weekly_bosses").select("id,life_class").execute().value
            let myClass = lifeClass?.rawValue
            let matched = pool.filter { $0.life_class == myClass }
            let general = pool.filter { $0.life_class == nil }
            let base = matched.isEmpty ? general : matched
            let others = base.filter { $0.id != b.currentBossId }
            guard let chosen = (others.isEmpty ? base : others).first else { return }
            try await client.from("user_weekly_bosses")
                .update(["boss_id": chosen.id.uuidString]).eq("id", value: b.rowId.uuidString).execute()
            try await client.from("user_weekly_bosses")
                .update(["progress": 0, "rerolls_used": b.rerollsUsed + 1]).eq("id", value: b.rowId.uuidString).execute()
            await loadOrSpawnWeeklyBoss()
        } catch {}
    }

    // MARK: - Library & reading (#15 / #16)

    struct BookVM: Identifiable, Equatable {
        let id: UUID
        let title: String
        let author: String
        let coverSymbol: String
        let pages: [String]
    }

    private struct BookRow: Decodable {
        let id: UUID
        let title: String
        let author: String
        let cover_symbol: String
        let pages: [String]
    }
    private struct ReadingSessionInsert: Encodable {
        let user_id: String
        let book_id: String
        let duration_seconds: Int
        let takeaway: String
        let xp_earned: Int
    }

    func loadBooks() async {
        guard let client else { return }
        do {
            let rows: [BookRow] = try await client.from("books")
                .select("id,title,author,cover_symbol,pages").execute().value
            let vms = rows.map { BookVM(id: $0.id, title: $0.title, author: $0.author, coverSymbol: $0.cover_symbol, pages: $0.pages) }
            await MainActor.run { self.books = vms }
        } catch {
            await MainActor.run { self.books = [] }
        }
    }

    /// Save a finished reading session and award +25 XP (toward Intelligence).
    func saveReadingSession(bookId: UUID, takeaway: String, durationSeconds: Int) async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let xpGain = ReadingFocusTimer.readingXP
        do {
            try await client.from("user_reading_sessions").insert(ReadingSessionInsert(
                user_id: uid.uuidString, book_id: bookId.uuidString,
                duration_seconds: durationSeconds, takeaway: takeaway, xp_earned: xpGain
            )).execute()

            let cur = ProgressionState(xp: xp, level: level, rank: Rank(rawValue: rankCode) ?? .e)
            let res = ProgressionEngine.apply(cur, xpGain: xpGain)
            let newInt = (stats["intelligence"] ?? 10) + 1
            try await client.from("profiles")
                .update(["xp": res.state.xp, "level": res.state.level, "intelligence": newInt])
                .eq("id", value: uid.uuidString).execute()
            try await client.from("profiles")
                .update(["rank": res.state.rank.rawValue]).eq("id", value: uid.uuidString).execute()

            await loadProfileStatus()
            await MainActor.run { self.rewardFlash = "+\(xpGain) XP — Wisdom absorbed" }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { self.rewardFlash = nil }
        } catch {}
    }

    // MARK: - Recovery + streak (#17)

    static func parseTimestamp(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }

    /// Update streak + detect 36h inactivity (RecoveryDetector). Call on dashboard open.
    func refreshActivity() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let now = Date()
        let iso = ISO8601DateFormatter().string(from: now)

        guard let last = lastActiveAt else {
            try? await client.from("profiles").update(["last_active_at": iso]).eq("id", value: uid.uuidString).execute()
            try? await client.from("profiles").update(["current_streak": 1]).eq("id", value: uid.uuidString).execute()
            await MainActor.run { self.streak = 1; self.needsRecovery = false; self.lastActiveAt = now }
            return
        }

        if RecoveryDetector.evaluate(lastActiveAt: last, now: now) == .inactive {
            try? await client.from("profiles").update(["current_streak": 0]).eq("id", value: uid.uuidString).execute()
            await MainActor.run { self.needsRecovery = true; self.streak = 0 }
            return
        }

        let newDay = !Calendar.current.isDate(last, inSameDayAs: now)
        let newStreak = newDay ? streak + 1 : streak
        try? await client.from("profiles").update(["last_active_at": iso]).eq("id", value: uid.uuidString).execute()
        try? await client.from("profiles").update(["current_streak": newStreak]).eq("id", value: uid.uuidString).execute()
        await MainActor.run { self.needsRecovery = false; self.streak = newStreak; self.lastActiveAt = now }
    }

    /// Complete the recovery quest: +50 XP, reset streak to 1, reopen the loop.
    func completeRecoveryQuest() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        let xpGain = 50
        let iso = ISO8601DateFormatter().string(from: Date())
        let cur = ProgressionState(xp: xp, level: level, rank: Rank(rawValue: rankCode) ?? .e)
        let res = ProgressionEngine.apply(cur, xpGain: xpGain)
        do {
            try await client.from("profiles")
                .update(["xp": res.state.xp, "level": res.state.level, "current_streak": 1])
                .eq("id", value: uid.uuidString).execute()
            try await client.from("profiles").update(["rank": res.state.rank.rawValue]).eq("id", value: uid.uuidString).execute()
            try await client.from("profiles").update(["last_active_at": iso]).eq("id", value: uid.uuidString).execute()
            await loadProfileStatus()
            await MainActor.run {
                self.needsRecovery = false
                self.rewardFlash = "Welcome back, Hunter! +50 XP"
            }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { self.rewardFlash = nil }
        } catch {}
    }

    // MARK: - Trophy room (#14)

    struct TrophyVM: Identifiable, Equatable {
        let id: UUID
        let title: String
        let badge: String
    }

    private struct TrophyBoss: Decodable {
        let title: String
        let badge_reward: String?
    }
    private struct TrophyJoin: Decodable {
        let id: UUID
        let weekly_bosses: TrophyBoss?
    }

    func loadTrophies() async {
        guard let client else { return }
        guard let uid = try? await client.auth.session.user.id else { return }
        do {
            let rows: [TrophyJoin] = try await client.from("user_weekly_bosses")
                .select("id,weekly_bosses(title,badge_reward)")
                .eq("user_id", value: uid.uuidString)
                .eq("status", value: "completed")
                .execute().value
            let vms = rows.map { TrophyVM(id: $0.id, title: $0.weekly_bosses?.title ?? "Boss", badge: $0.weekly_bosses?.badge_reward ?? "champion") }
            await MainActor.run { self.trophies = vms }
        } catch {
            await MainActor.run { self.trophies = [] }
        }
    }
}
