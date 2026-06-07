import Foundation

// OnboardingValidator — pure validation of the onboarding draft (#4).
// Empty list = valid. Errors are ordered: name, goals, life class, height, weight.

public enum MainGoal: CaseIterable, Equatable, Sendable {
    case buildBody, buildSkill, buildMind, buildMoney, buildConfidence, buildDiscipline
}

public struct OnboardingDraft: Equatable, Sendable {
    public var characterName: String
    public var goals: [MainGoal]
    public var lifeClass: LifeClass?
    public var intensity: Intensity
    public var heightCm: Double?
    public var weightKg: Double?

    public init(
        characterName: String = "",
        goals: [MainGoal] = [],
        lifeClass: LifeClass? = nil,
        intensity: Intensity = .normal,
        heightCm: Double? = nil,
        weightKg: Double? = nil
    ) {
        self.characterName = characterName
        self.goals = goals
        self.lifeClass = lifeClass
        self.intensity = intensity
        self.heightCm = heightCm
        self.weightKg = weightKg
    }
}

public enum OnboardingError: Equatable, Sendable {
    case emptyName
    case invalidName
    case noGoal
    case noLifeClass
    case invalidHeight
    case invalidWeight
}

public enum OnboardingValidator {
    public static let nameRange = 2...20
    public static let heightRange = 50.0...300.0
    public static let weightRange = 20.0...500.0

    public static func validate(_ draft: OnboardingDraft) -> [OnboardingError] {
        var errors: [OnboardingError] = []

        let name = draft.characterName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            errors.append(.emptyName)
        } else if !nameRange.contains(name.count) {
            errors.append(.invalidName)
        }

        if draft.goals.isEmpty {
            errors.append(.noGoal)
        }
        if draft.lifeClass == nil {
            errors.append(.noLifeClass)
        }
        if let h = draft.heightCm, heightRange.contains(h) {} else {
            errors.append(.invalidHeight)
        }
        if let w = draft.weightKg, weightRange.contains(w) {} else {
            errors.append(.invalidWeight)
        }
        return errors
    }
}
