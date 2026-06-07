// QuestRewardCalculator — XP + stat reward for completing a daily/standard quest.
// Spec (PRD #1, #7): E=50/+1, D=100/+2, C=150/+3, B=250/+5, A=400/+8.
//   Attaching proof adds +20 XP (stat unchanged). S-rank is reserved for the
//   weekly boss and handled by WeeklyBossLifecycle, so it is not a Difficulty here.

public enum Difficulty: Equatable, Sendable {
    case e, d, c, b, a
}

public struct QuestReward: Equatable, Sendable {
    public let xp: Int
    public let statDelta: Int

    public init(xp: Int, statDelta: Int) {
        self.xp = xp
        self.statDelta = statDelta
    }
}

public enum QuestRewardCalculator {
    public static func reward(difficulty: Difficulty, proofAttached: Bool) -> QuestReward {
        let base: QuestReward = switch difficulty {
        case .e: QuestReward(xp: 50, statDelta: 1)
        case .d: QuestReward(xp: 100, statDelta: 2)
        case .c: QuestReward(xp: 150, statDelta: 3)
        case .b: QuestReward(xp: 250, statDelta: 5)
        case .a: QuestReward(xp: 400, statDelta: 8)
        }
        let proofBonus = proofAttached ? 20 : 0
        return QuestReward(xp: base.xp + proofBonus, statDelta: base.statDelta)
    }
}
