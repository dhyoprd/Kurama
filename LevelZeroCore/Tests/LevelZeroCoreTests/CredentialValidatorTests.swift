import Testing
@testable import LevelZeroCore

@Suite struct CredentialValidatorTests {
    // Behavior 1: well-formed email + long-enough password -> no errors.
    @Test func validCredentialsHaveNoErrors() {
        #expect(CredentialValidator.validate(email: "jin@example.com", password: "secret1").isEmpty)
    }

    // Behavior 2: empty email -> emptyEmail.
    @Test func emptyEmailFlagged() {
        #expect(CredentialValidator.validate(email: "", password: "secret1") == [.emptyEmail])
        #expect(CredentialValidator.validate(email: "   ", password: "secret1") == [.emptyEmail])
    }

    // Behavior 3: non-empty but malformed email -> invalidEmail.
    @Test(arguments: ["notanemail", "a@b", "@example.com", "jin@", "jin@@x.com", "j in@x.com"])
    func malformedEmailFlagged(_ email: String) {
        #expect(CredentialValidator.validate(email: email, password: "secret1") == [.invalidEmail])
    }

    // Behavior 4: empty password -> emptyPassword.
    @Test func emptyPasswordFlagged() {
        #expect(CredentialValidator.validate(email: "jin@example.com", password: "") == [.emptyPassword])
    }

    // Behavior 5: password shorter than the minimum -> passwordTooShort.
    @Test func shortPasswordFlagged() {
        #expect(CredentialValidator.validate(email: "jin@example.com", password: "abc12") == [.passwordTooShort])
    }

    // Behavior 6: multiple problems combine, email error before password error.
    @Test func errorsCombineInOrder() {
        #expect(CredentialValidator.validate(email: "", password: "abc") == [.emptyEmail, .passwordTooShort])
        #expect(CredentialValidator.validate(email: "bad", password: "") == [.invalidEmail, .emptyPassword])
    }
}
