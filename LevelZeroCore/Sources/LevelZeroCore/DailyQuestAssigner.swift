// DailyQuestAssigner — picks the day's quests. Pure; randomness injected.
// Spec (PRD #5/#6, design doc B):
//   - Idempotent per day: if quests already exist for today, assign nothing.
//   - Pick `dailyCount` quests matched to the user's life class + intensity.
//   - Fall back to general quests when the class-specific pool is too small.
// Intensity -> allowed difficulty (decision; design doc is silent on the exact
// mapping): easy {E,D}, normal {D,C,B}, hard {B,A}.

public enum DailyQuestAssigner {
    public static let dailyCount = 3

    public static func allowedDifficulties(for intensity: Intensity) -> [Difficulty] {
        switch intensity {
        case .easy:   return [.e, .d]
        case .normal: return [.d, .c, .b]
        case .hard:   return [.b, .a]
        }
    }

    public static func assign(
        lifeClass: LifeClass,
        intensity: Intensity,
        alreadyAssignedToday: Bool,
        pool: [Quest],
        using rng: inout some RandomNumberGenerator,
        count: Int = dailyCount
    ) -> [Quest] {
        guard !alreadyAssignedToday else { return [] }
        let allowed = Set(allowedDifficulties(for: intensity))

        let specific = pool
            .filter { $0.lifeClass == lifeClass && allowed.contains($0.difficulty) }
            .shuffled(using: &rng)
        var picked = Array(specific.prefix(count))

        if picked.count < count {
            let general = pool
                .filter { $0.lifeClass == nil && allowed.contains($0.difficulty) }
                .shuffled(using: &rng)
            picked += general.prefix(count - picked.count)
        }
        return picked
    }
}
