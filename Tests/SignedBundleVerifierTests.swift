import Foundation
@main struct SignedBundleVerifierTests {
    static func main() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }
        let app = root.appendingPathComponent("Forged.app")
        try fm.createDirectory(at: app.appendingPathComponent("Contents/MacOS"), withIntermediateDirectories: true)
        let info: [String: Any] = ["CFBundleIdentifier": "com.fmdigitech.WireTunnels", "CFBundleExecutable": "fake", "CFBundlePackageType": "APPL"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: app.appendingPathComponent("Contents/Info.plist"))
        try fm.copyItem(atPath: "/usr/bin/true", toPath: app.appendingPathComponent("Contents/MacOS/fake").path)
        precondition(!SignedBundleVerifier.isValid(app, identifier: "com.fmdigitech.WireTunnels", team: "C72ZK246A3"))
        precondition(!SignedBundleVerifier.isValid(root.appendingPathComponent("Missing.app"), identifier: "com.fmdigitech.WireTunnels", team: "C72ZK246A3"))
        if CommandLine.arguments.count == 2 {
            let source = URL(fileURLWithPath: CommandLine.arguments[1])
            let copy = root.appendingPathComponent("Snapshot.app")
            try fm.copyItem(at: source, to: copy)
            precondition(SignedBundleVerifier.isValid(copy, identifier: "com.fmdigitech.WireTunnels", team: "C72ZK246A3"))
            precondition(!SignedBundleVerifier.isValid(copy, identifier: "com.fmdigitech.WireTunnels", team: "WRONGTEAM"))
            let tool = copy.appendingPathComponent("Contents/Resources/wireguard/wg-quick")
            var data = try Data(contentsOf: tool)
            data.append(Data("\n# tampered fixture\n".utf8))
            try data.write(to: tool)
            precondition(!SignedBundleVerifier.isValid(copy, identifier: "com.fmdigitech.WireTunnels", team: "C72ZK246A3"))
            print("PASS: signed snapshot accepted; wrong team and modified tool rejected")
        }
        print("PASS: missing and forged bundle rejected despite Apple-signed executable")
    }
}
