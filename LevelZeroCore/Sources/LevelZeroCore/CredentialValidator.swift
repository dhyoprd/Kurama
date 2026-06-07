import Foundation

// CredentialValidator — pure email/password validation for auth (#3).
// Returns the list of problems; an empty list means valid. Email errors come
// before password errors; each field contributes at most one error.

public enum CredentialError: Equatable, Sendable {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case passwordTooShort
}

public enum CredentialValidator {
    public static let minPasswordLength = 6

    public static func validate(email: String, password: String) -> [CredentialError] {
        var errors: [CredentialError] = []
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            errors.append(.emptyEmail)
        } else if !isValidEmail(trimmedEmail) {
            errors.append(.invalidEmail)
        }

        if password.isEmpty {
            errors.append(.emptyPassword)
        } else if password.count < minPasswordLength {
            errors.append(.passwordTooShort)
        }
        return errors
    }

    private static func isValidEmail(_ email: String) -> Bool {
        guard !email.contains(" ") else { return false }
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }
        let local = parts[0]
        let domain = parts[1]
        guard !local.isEmpty, !domain.isEmpty else { return false }
        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        return labels.count >= 2 && labels.allSatisfy { !$0.isEmpty }
    }
}
