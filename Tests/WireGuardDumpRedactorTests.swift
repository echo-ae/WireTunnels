import Foundation

@main
struct WireGuardDumpRedactorTests {
    static func main() {
        let input = "utun7\tPRIVATE_SECRET\tpublic\t51820\toff\n"
            + "utun7\tpeer\tPSK_SECRET\t127.0.0.1:51820\t10.0.0.0/24\t123\t45\t67\t25\n"
            + "unexpected\tUNKNOWN_SECRET\n"
        let output = WireGuardDumpRedactor.redact(input)
        precondition(WireGuardDumpRedactor.redact(input, interfaces: []).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        precondition(WireGuardDumpRedactor.redact(input, interfaces: ["utun7"]) == output)
        precondition(!output.contains("SECRET"))
        precondition(output.contains("utun7\t(hidden)\tpublic\t51820\toff"))
        precondition(output.contains("utun7\tpeer\t(hidden)\t127.0.0.1:51820\t10.0.0.0/24\t123\t45\t67\t25"))
        precondition(WireGuardDumpRedactor.redact("") == "")
        precondition(WireGuardDumpRedactor.redact(output) == output)
        print("PASS: private and preshared keys removed; status preserved; unknown records suppressed")
    }
}
