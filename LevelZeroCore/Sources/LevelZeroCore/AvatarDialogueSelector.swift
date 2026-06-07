// AvatarDialogueSelector — Tap-to-Speak. Picks a motivational line aimed at the
// user's weakest stat. Pure; randomness injected for deterministic tests.

public enum AvatarDialogueSelector {
    /// The user's weakest stat. Ties break by canonical `Stat` order.
    public static func weakestStat(of stats: Stats) -> Stat {
        // min(by:) returns the first minimum -> ties break by canonical Stat order.
        return Stat.allCases.min { stats.value($0) < stats.value($1) }!
    }

    /// A motivational line for the given weakest stat.
    public static func lines(for stat: Stat) -> [String] {
        switch stat {
        case .strength:
            return ["Your body's been waiting. One set today.",
                    "Strength is built rep by rep. Start now."]
        case .intelligence:
            return ["Feed your mind — ten pages.",
                    "Learn one new thing today."]
        case .discipline:
            return ["A small promise, kept. That's discipline.",
                    "Show up, even briefly. That's the win."]
        case .charisma:
            return ["Say hi to one person today.",
                    "Your voice matters. Use it."]
        case .wealth:
            return ["Track one expense. Wealth starts there.",
                    "Save a little today, future you smiles."]
        case .mind:
            return ["Breathe. Two minutes of stillness.",
                    "Rest the mind to sharpen it."]
        }
    }

    /// Pick a line for the user's weakest stat using the given generator.
    public static func line(
        for stats: Stats,
        using rng: inout some RandomNumberGenerator
    ) -> String {
        let stat = weakestStat(of: stats)
        let pool = lines(for: stat)
        return pool[Int.random(in: 0..<pool.count, using: &rng)]
    }
}
