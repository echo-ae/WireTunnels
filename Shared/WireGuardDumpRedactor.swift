import Foundation

/// Only the documented `wg show all dump` records may leave the helper.
/// Unknown shapes are discarded rather than risking disclosure of a new secret field.
enum WireGuardDumpRedactor {
    static func redact(_ dump: String, interfaces: Set<String>? = nil) -> String {
        dump.components(separatedBy: "\n").compactMap { line -> String? in
            if line.isEmpty { return "" }
            var fields = line.components(separatedBy: "\t")
            if let interfaces, !interfaces.contains(fields[0]) { return nil }
            switch fields.count {
            case 5: fields[1] = "(hidden)" // interface private key
            case 9: fields[2] = "(hidden)" // peer preshared key
            default: return nil
            }
            return fields.joined(separator: "\t")
        }.joined(separator: "\n")
    }
}
