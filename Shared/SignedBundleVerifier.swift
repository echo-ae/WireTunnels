import Foundation
import Security

enum SignedBundleVerifier {
    static func isValid(_ bundle: URL, identifier: String, team: String) -> Bool {
        var code: SecStaticCode?
        var requirement: SecRequirement?
        // Values come only from compile-time constants, never XPC input.
        let text = "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(team)\""
        guard SecStaticCodeCreateWithPath(bundle as CFURL, [], &code) == errSecSuccess,
              let code,
              SecRequirementCreateWithString(text as CFString, [], &requirement) == errSecSuccess,
              let requirement else { return false }
        return SecStaticCodeCheckValidity(code,
            SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate | kSecCSCheckNestedCode),
            requirement) == errSecSuccess
    }
}
