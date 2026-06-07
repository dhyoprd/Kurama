import Testing
@testable import LevelZeroCore

@Suite struct DailyQuestAssignerTests {
    // A pool of warrior E/D quests, easy intensity should pick from these.
    static let warriorPool: [Quest] = [
        Quest(id: "w1", lifeClass: .warrior, difficulty: .e),
        Quest(id: "w2", lifeClass: .warrior, difficulty: .d),
        Quest(id: "w3", lifeClass: .warrior, difficulty: .e),
        Quest(id: "w4", lifeClass: .warrior, difficulty: .d),
        Quest(id: "w5", lifeClass: .warrior, difficulty: .e),
    ]

    // Behavior 1: when none assigned today and pool is sufficient -> 3 quests.
    @Test func assignsThreeWhenNoneToday() {
        var rng = SeededRandomNumberGenerator(seed: 1)
        let picked = DailyQuestAssigner.assign(
            lifeClass: .warrior, intensity: .easy,
            alreadyAssignedToday: false, pool: Self.warriorPool, using: &rng
        )
        #expect(picked.count == 3)
    }

    // Behavior 2: idempotent — if today already has quests, assign nothing.
    @Test func assignsNothingWhenAlreadyAssigned() {
        var rng = SeededRandomNumberGenerator(seed: 1)
        let picked = DailyQuestAssigner.assign(
            lifeClass: .warrior, intensity: .easy,
            alreadyAssignedToday: true, pool: Self.warriorPool, using: &rng
        )
        #expect(picked.isEmpty)
    }

    // Behavior 3: only matching class + allowed difficulty are picked.
    @Test func picksOnlyMatchingClassAndDifficulty() {
        let mixed: [Quest] = [
            Quest(id: "w-e", lifeClass: .warrior, difficulty: .e),
            Quest(id: "w-d", lifeClass: .warrior, difficulty: .d),
            Quest(id: "w-a", lifeClass: .warrior, difficulty: .a),  // out of easy band
            Quest(id: "s-e", lifeClass: .scholar, difficulty: .e),  // wrong class
            Quest(id: "g-e", lifeClass: nil, difficulty: .e),       // general fallback
        ]
        var rng = SeededRandomNumberGenerator(seed: 3)
        let picked = DailyQuestAssigner.assign(
            lifeClass: .warrior, intensity: .easy,
            alreadyAssignedToday: false, pool: mixed, using: &rng
        )
        #expect(picked.count == 3)
        #expect(picked.allSatisfy {
            ($0.lifeClass == .warrior || $0.lifeClass == nil)
                && [.e, .d].contains($0.difficulty)
        })
        #expect(!picked.contains { $0.id == "w-a" || $0.id == "s-e" })
    }

    // Behavior 4: fallback to general quests when class-specific is insufficient.
    @Test func fallsBackToGeneral() {
        let pool: [Quest] = [
            Quest(id: "w-e", lifeClass: .warrior, difficulty: .e),
            Quest(id: "g-d1", lifeClass: nil, difficulty: .d),
            Quest(id: "g-d2", lifeClass: nil, difficulty: .d),
            Quest(id: "g-d3", lifeClass: nil, difficulty: .d),
        ]
        var rng = SeededRandomNumberGenerator(seed: 9)
        let picked = DailyQuestAssigner.assign(
            lifeClass: .warrior, intensity: .easy,
            alreadyAssignedToday: false, pool: pool, using: &rng
        )
        #expect(picked.count == 3)
        #expect(picked.contains { $0.id == "w-e" })          // specific included
        #expect(picked.filter { $0.lifeClass == nil }.count == 2) // 2 general fill
    }

    // Behavior 5: deterministic with a fixed seed.
    @Test func deterministicWithSeed() {
        var a = SeededRandomNumberGenerator(seed: 5)
        var b = SeededRandomNumberGenerator(seed: 5)
        let pa = DailyQuestAssigner.assign(lifeClass: .warrior, intensity: .easy,
                                           alreadyAssignedToday: false, pool: Self.warriorPool, using: &a)
        let pb = DailyQuestAssigner.assign(lifeClass: .warrior, intensity: .easy,
                                           alreadyAssignedToday: false, pool: Self.warriorPool, using: &b)
        #expect(pa.map(\.id) == pb.map(\.id))
    }
}
