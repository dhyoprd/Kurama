// AvatarPromptSelector — builds the full-body AI image prompt for avatar
// generation/evolution. Pure string builder.
// Spec (design doc E): physical evolution by the user's HIGHEST stat ->
//   3 archetypes, scaled across 6 rank tiers (E..S).
//   - strength, discipline      -> warrior (muscular build, heavy armor)
//   - intelligence, mind        -> mage    (glowing robes, floating tome, aura)
//   - wealth, charisma          -> noble   (techno-nobility, gold neon)
// (Design doc names STR / INT-MIND / WEA-CHA; discipline is mapped to warrior
//  to match the Warrior class's fitness+discipline focus.)

public enum Archetype: Equatable, Sendable {
    case warrior, mage, noble
}

public enum AvatarPromptSelector {
    /// The evolution archetype for a stat.
    public static func archetype(for stat: Stat) -> Archetype {
        switch stat {
        case .strength, .discipline:   return .warrior
        case .intelligence, .mind:     return .mage
        case .wealth, .charisma:       return .noble
        }
    }

    /// The user's highest stat. Ties break by canonical `Stat` order (first wins).
    public static func topStat(of stats: Stats) -> Stat {
        Stat.allCases.reduce(Stat.strength) { best, s in
            stats.value(s) > stats.value(best) ? s : best
        }
    }

    /// Full-body prompt for a given rank tier and top stat.
    public static func prompt(rank: Rank, topStat: Stat) -> String {
        let body = "A full-body standing RPG character portrait"
        let tier = tierDescriptor(rank)
        let flavor = archetypeDescriptor(archetype(for: topStat))
        return "\(body), \(tier), \(flavor), standing pose, cyberpunk neon highlights, dark background, 8k"
    }

    static func tierDescriptor(_ rank: Rank) -> String {
        switch rank {
        case .e: return "level 1 novice, simple leather gear"
        case .d: return "level 15 adept, reinforced iron gear, slight neon aura"
        case .c: return "level 30 elite, glowing runic gear, floating energy particles"
        case .b: return "level 45 master, mystical plate gear, intense glowing aura"
        case .a: return "level 65 grandmaster, legendary crystal gear, levitating artifacts"
        case .s: return "level 99 monarch, divine glowing gear, massive neon energy wings"
        }
    }

    static func archetypeDescriptor(_ a: Archetype) -> String {
        switch a {
        case .warrior: return "muscular athletic build, heavy battle armor"
        case .mage:    return "glowing mage robes, floating ancient tome, blue-white energy aura"
        case .noble:   return "techno-nobility regalia, gold neon accents, advanced cyber weapon"
        }
    }
}
