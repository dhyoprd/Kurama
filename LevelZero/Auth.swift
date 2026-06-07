import SwiftUI
import LevelZeroCore

/// Top-level gate: routes to the app when authenticated, else to AuthView.
struct RootGate: View {
    @StateObject private var supa = SupabaseManager.shared

    var body: some View {
        Group {
            if !supa.isAuthenticated {
                AuthView()
            } else if !supa.hasProfile {
                OnboardingView()
            } else {
                TabViewShell()
            }
        }
        .preferredColorScheme(.dark)
        .task {
            supa.observeAuth()
            await supa.refreshSession()
            await supa.loadProfileStatus()
        }
    }
}

/// Email/password sign in + sign up. Validates with the pure CredentialValidator
/// before hitting Supabase.
struct AuthView: View {
    @StateObject private var supa = SupabaseManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errors: [CredentialError] = []
    @State private var serverMessage: String?
    @State private var loading = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("LEVEL ZERO")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.neonCyan)
                Text(isSignUp ? "Create your account" : "Welcome back, adventurer")
                    .foregroundStyle(Theme.subtext)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Theme.card)
                    .cornerRadius(8)
                    .foregroundStyle(Theme.text)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Theme.card)
                    .cornerRadius(8)
                    .foregroundStyle(Theme.text)

                if !errors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(errors, id: \.self) { err in
                            Text("• \(message(for: err))")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let serverMessage {
                    Text(serverMessage)
                        .font(.caption)
                        .foregroundStyle(Theme.gold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: submit) {
                    HStack {
                        if loading { ProgressView().tint(Theme.background) }
                        Text(isSignUp ? "Create account" : "Sign in").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.neonCyan)
                    .foregroundStyle(Theme.background)
                    .cornerRadius(10)
                }
                .disabled(loading)

                Button(isSignUp ? "Have an account? Sign in" : "New here? Create account") {
                    isSignUp.toggle()
                    errors = []
                    serverMessage = nil
                }
                .font(.caption)
                .foregroundStyle(Theme.neonCyan)
            }
            .padding(24)
        }
    }

    private func submit() {
        errors = CredentialValidator.validate(email: email, password: password)
        guard errors.isEmpty else { return }
        loading = true
        serverMessage = nil
        Task {
            do {
                if isSignUp {
                    let loggedIn = try await supa.signUp(email: email, password: password)
                    if !loggedIn {
                        serverMessage = "Check your email to confirm, then sign in."
                        isSignUp = false
                    }
                } else {
                    try await supa.signIn(email: email, password: password)
                }
            } catch {
                serverMessage = error.localizedDescription
            }
            loading = false
        }
    }

    private func message(for error: CredentialError) -> String {
        switch error {
        case .emptyEmail: return "Email is required."
        case .invalidEmail: return "Enter a valid email address."
        case .emptyPassword: return "Password is required."
        case .passwordTooShort: return "Password must be at least \(CredentialValidator.minPasswordLength) characters."
        }
    }
}
