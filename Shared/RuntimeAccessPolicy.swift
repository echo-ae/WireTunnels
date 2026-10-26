import Foundation

enum RuntimeAccessPolicy {
    enum Action { case connect, disconnect }
    static func canStage(uid: Int, owner: Int?, exists: Bool) -> Bool {
        if let owner { return owner == uid }
        return !exists // Never silently claim a legacy/unknown configuration.
    }
    static func canUseManaged(action: Action, connect: Bool, disconnect: Bool) -> Bool {
        switch action { case .connect: return connect; case .disconnect: return disconnect }
    }
}
