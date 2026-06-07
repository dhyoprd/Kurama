// ProgressionEngine — XP / level / rank progression.
// Decision (PRD #1, #7): per-level XP with roll-over, increasing cost.
//   xp = progress WITHIN the current level (not lifetime total).
//   advance L -> L+1 costs L*100 XP.

public enum Rank: Equatable, Sendable {
    case e, d, c, b, a, s
}

public struct ProgressionState: Equatable, Sendable {
    public var xp: Int
    public var level: Int
    public var rank: Rank

    public init(xp: Int = 0, level: Int = 1, rank: Rank = .e) {
        self.xp = xp
        self.level = level
        self.rank = rank
    }
}

public enum ProgressionEvent: Equatable, Sendable {
    case leveledUp(to: Int)
    case rankedUp(to: Rank)
}

public enum ProgressionEngine {
    /// Apply an XP gain. Returns the new state and the events that occurred.
    public static func apply(
        _ state: ProgressionState,
        xpGain: Int
    ) -> (state: ProgressionState, events: [ProgressionEvent]) {
        var s = state
        var events: [ProgressionEvent] = []
        s.xp += xpGain
        while s.xp >= s.level * 100 {
            s.xp -= s.level * 100
            s.level += 1
            events.append(.leveledUp(to: s.level))
        }
        let newRank = rank(forLevel: s.level)
        if newRank != s.rank {
            s.rank = newRank
            events.append(.rankedUp(to: newRank))
        }
        return (s, events)
    }

    /// Rank band for a level. E 1–10, D 11–20, C 21–35, B 36–50, A 51–75, S 76+.
    public static func rank(forLevel level: Int) -> Rank {
        switch level {
        case ..<11: return .e
        case ..<21: return .d
        case ..<36: return .c
        case ..<51: return .b
        case ..<76: return .a
        default:    return .s
        }
    }
}
