import Testing
@testable import LevelZeroCore

@Suite struct QuestRewardCalculatorTests {
    // Behavior 1: E-rank, no proof -> 50 XP / +1 stat.
    @Test func eRankNoProof() {
        let r = QuestRewardCalculator.reward(difficulty: .e, proofAttached: false)
        #expect(r == QuestReward(xp: 50, statDelta: 1))
    }

    // Behavior 2: base xp/stat per difficulty (no proof).
    @Test(arguments: [
        (Difficulty.e, 50, 1), (.d, 100, 2), (.c, 150, 3), (.b, 250, 5), (.a, 400, 8),
    ])
    func baseRewardPerDifficulty(_ t: (Difficulty, Int, Int)) {
        let r = QuestRewardCalculator.reward(difficulty: t.0, proofAttached: false)
        #expect(r == QuestReward(xp: t.1, statDelta: t.2))
    }

    // Behavior 3: proof adds +20 XP, stat unchanged.
    @Test(arguments: [
        (Difficulty.e, 70, 1), (.d, 120, 2), (.c, 170, 3), (.b, 270, 5), (.a, 420, 8),
    ])
    func proofAddsTwentyXP(_ t: (Difficulty, Int, Int)) {
        let r = QuestRewardCalculator.reward(difficulty: t.0, proofAttached: true)
        #expect(r == QuestReward(xp: t.1, statDelta: t.2))
    }
}
