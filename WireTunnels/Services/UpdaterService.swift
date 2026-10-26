import Foundation
import Combine

/// Private fork: never replace our hardened build with an upstream Sparkle release.
/// Re-enable only after provisioning a separate signed feed and update key.
@MainActor
final class UpdaterService: ObservableObject {
    @Published private(set) var canCheckForUpdates = false
    @Published private(set) var automaticallyChecksForUpdates = false
    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {}
    func checkForUpdates() {}
}
