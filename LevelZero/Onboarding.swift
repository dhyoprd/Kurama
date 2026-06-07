import SwiftUI
import LevelZeroCore

// MARK: - Display + DB mappings (app layer keeps persistence strings out of core)

extension MainGoal {
    var displayName: String {
        switch self {
        case .buildBody: return "Build Body"
        case .buildSkill: return "Build Skill"
        case .buildMind: return "Build Mind"
        case .buildMoney: return "Build Money"
        case .buildConfidence: return "Build Confidence"
        case .buildDiscipline: return "Build Discipline"
        }
    }
    var dbValue: String {
        switch self {
        case .buildBody: return "build_body"
        case .buildSkill: return "build_skill"
        case .buildMind: return "build_mind"
        case .buildMoney: return "build_money"
        case .buildConfidence: return "build_confidence"
        case .buildDiscipline: return "build_discipline"
        }
    }
}

extension LifeClass {
    var displayName: String { rawValue.capitalized }
    var dbValue: String { rawValue }
}

extension Intensity {
    var displayName: String { rawValue.capitalized }
    var dbValue: String { rawValue }
}

// MARK: - Onboarding

struct OnboardingView: View {
    @StateObject private var supa = SupabaseManager.shared
    @State private var name = ""
    @State private var goals: Set<MainGoal> = []
    @State private var lifeClass: LifeClass?
    @State private var intensity: Intensity = .normal
    @State private var heightText = ""
    @State private var weightText = ""
    @State private var errors: [OnboardingError] = []
    @State private var serverMessage: String?
    @State private var loading = false

    private var draft: OnboardingDraft {
        OnboardingDraft(
            characterName: name,
            goals: Array(goals),
            lifeClass: lifeClass,
            intensity: intensity,
            heightCm: Double(heightText),
            weightKg: Double(weightText)
        )
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("CREATE YOUR CHARACTER")
                        .font(.title.bold())
                        .foregroundStyle(Theme.neonCyan)

                    section("Character name") {
                        TextField("e.g. JinWoo", text: $name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding().background(Theme.card).cornerRadius(8)
                            .foregroundStyle(Theme.text)
                    }

                    section("Main goals (pick 1 or more)") {
                        VStack(spacing: 8) {
                            ForEach(MainGoal.allCases, id: \.self) { goal in
                                selectRow(goal.displayName, selected: goals.contains(goal)) {
                                    if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
                                }
                            }
                        }
                    }

                    section("Life class") {
                        VStack(spacing: 8) {
                            ForEach(LifeClass.allCases, id: \.self) { c in
                                selectRow(c.displayName, selected: lifeClass == c) { lifeClass = c }
                            }
                        }
                    }

                    section("Intensity") {
                        Picker("", selection: $intensity) {
                            ForEach(Intensity.allCases, id: \.self) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 12) {
                        section("Height (cm)") { numberField($heightText) }
                        section("Weight (kg)") { numberField($weightText) }
                    }

                    if !errors.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(errors, id: \.self) { err in
                                Text("• \(message(for: err))").font(.caption).foregroundStyle(.red)
                            }
                        }
                    }
                    if let serverMessage {
                        Text(serverMessage).font(.caption).foregroundStyle(Theme.gold)
                    }

                    Button(action: submit) {
                        HStack {
                            if loading { ProgressView().tint(Theme.background) }
                            Text("Generate character").bold()
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(Theme.neonCyan).foregroundStyle(Theme.background).cornerRadius(10)
                    }
                    .disabled(loading)
                }
                .padding(24)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(Theme.subtext)
            content()
        }
    }

    private func selectRow(_ label: String, selected: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label).foregroundStyle(Theme.text)
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.neonCyan) }
            }
            .padding()
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? Theme.neonCyan : .clear, lineWidth: 1))
            .cornerRadius(8)
        }
    }

    private func numberField(_ binding: Binding<String>) -> some View {
        TextField("0", text: binding)
            .keyboardType(.decimalPad)
            .padding().background(Theme.card).cornerRadius(8)
            .foregroundStyle(Theme.text)
    }

    private func message(for error: OnboardingError) -> String {
        switch error {
        case .emptyName: return "Name is required."
        case .invalidName: return "Name must be 2–20 characters."
        case .noGoal: return "Pick at least one goal."
        case .noLifeClass: return "Choose a life class."
        case .invalidHeight: return "Enter a valid height (50–300 cm)."
        case .invalidWeight: return "Enter a valid weight (20–500 kg)."
        }
    }

    private func submit() {
        errors = OnboardingValidator.validate(draft)
        guard errors.isEmpty else { return }
        loading = true
        serverMessage = nil
        Task {
            do {
                try await supa.createProfile(from: draft)
            } catch {
                serverMessage = error.localizedDescription
            }
            loading = false
        }
    }
}
