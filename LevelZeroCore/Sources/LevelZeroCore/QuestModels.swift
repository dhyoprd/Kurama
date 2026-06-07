// Shared quest-domain types.

public enum LifeClass: String, CaseIterable, Equatable, Sendable {
    case warrior, scholar, builder, monk, strategist
}

public enum Intensity: String, CaseIterable, Equatable, Sendable {
    case easy, normal, hard
}

/// A quest from the master pool. `lifeClass == nil` means a general quest
/// usable as fallback for any class. Only the fields the assigner needs are
/// modeled here; reward fields live with QuestRewardCalculator.
public struct Quest: Equatable, Sendable, Identifiable {
    public let id: String
    public let lifeClass: LifeClass?
    public let difficulty: Difficulty

    public init(id: String, lifeClass: LifeClass?, difficulty: Difficulty) {
        self.id = id
        self.lifeClass = lifeClass
        self.difficulty = difficulty
    }
}
