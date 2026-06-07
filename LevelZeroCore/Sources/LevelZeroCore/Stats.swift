// Stats — the six character stats. Shared across avatar cores.
// Canonical order (used for deterministic tie-breaks):
// strength, intelligence, discipline, charisma, wealth, mind.

public enum Stat: CaseIterable, Equatable, Sendable {
    case strength, intelligence, discipline, charisma, wealth, mind
}

public struct Stats: Equatable, Sendable {
    public var strength: Int
    public var intelligence: Int
    public var discipline: Int
    public var charisma: Int
    public var wealth: Int
    public var mind: Int

    public init(
        strength: Int = 10,
        intelligence: Int = 10,
        discipline: Int = 10,
        charisma: Int = 10,
        wealth: Int = 10,
        mind: Int = 10
    ) {
        self.strength = strength
        self.intelligence = intelligence
        self.discipline = discipline
        self.charisma = charisma
        self.wealth = wealth
        self.mind = mind
    }

    public func value(_ stat: Stat) -> Int {
        switch stat {
        case .strength:     return strength
        case .intelligence: return intelligence
        case .discipline:   return discipline
        case .charisma:     return charisma
        case .wealth:       return wealth
        case .mind:         return mind
        }
    }
}
