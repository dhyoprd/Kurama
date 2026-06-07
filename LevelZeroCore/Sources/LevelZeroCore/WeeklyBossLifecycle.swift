import Foundation

// WeeklyBossLifecycle — pure state machine for the weekly boss.
// Spec (design doc C, PRD #11/#12). Operates on offsets from `weekStart`
// (Monday 00:00, computed by the caller at spawn) so it needs no weekday
// parsing and stays deterministic:
//   - reroll allowed at most once, before Wednesday 23:59  (~ weekStart + 3 days)
//   - conquer allowed until Sunday 23:59                   (~ weekStart + 7 days)
//   - past the conquer deadline an unfinished boss auto-fails (no XP penalty)
// Windows use fixed 24h days.

public enum BossStatus: Equatable, Sendable {
    case active, completed, failed
}

public struct BossReward: Equatable, Sendable {
    public let xp: Int
    public let statBonus: Int
    public init(xp: Int, statBonus: Int) {
        self.xp = xp
        self.statBonus = statBonus
    }
}

public struct BossState: Equatable, Sendable {
    public var status: BossStatus
    public var weekStart: Date
    public var rerollsUsed: Int

    public init(status: BossStatus = .active, weekStart: Date, rerollsUsed: Int = 0) {
        self.status = status
        self.weekStart = weekStart
        self.rerollsUsed = rerollsUsed
    }
}

public enum WeeklyBossLifecycle {
    public static let rerollWindow: TimeInterval = 3 * 24 * 3600
    public static let activeWindow: TimeInterval = 7 * 24 * 3600
    public static let maxRerolls = 1
    public static let reward = BossReward(xp: 1000, statBonus: 15)

    public static func canReroll(_ s: BossState, now: Date) -> Bool {
        s.status == .active
            && s.rerollsUsed < maxRerolls
            && now < s.weekStart.addingTimeInterval(rerollWindow)
    }

    public static func reroll(_ s: BossState, now: Date) -> BossState {
        guard canReroll(s, now: now) else { return s }
        var out = s
        out.rerollsUsed += 1
        return out
    }

    public static func conquer(_ s: BossState, now: Date) -> (state: BossState, reward: BossReward?) {
        guard s.status == .active,
              now < s.weekStart.addingTimeInterval(activeWindow) else {
            return (s, nil)
        }
        var out = s
        out.status = .completed
        return (out, reward)
    }

    public static func evaluate(_ s: BossState, now: Date) -> BossState {
        guard s.status == .active,
              now >= s.weekStart.addingTimeInterval(activeWindow) else {
            return s
        }
        var out = s
        out.status = .failed
        return out
    }
}
