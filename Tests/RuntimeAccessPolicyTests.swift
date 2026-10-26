import Foundation
@main struct RuntimeAccessPolicyTests {
    static func main() {
        precondition(RuntimeAccessPolicy.canStage(uid: 501, owner: nil, exists: false))
        precondition(!RuntimeAccessPolicy.canStage(uid: 501, owner: nil, exists: true))
        precondition(RuntimeAccessPolicy.canStage(uid: 501, owner: 501, exists: true))
        precondition(!RuntimeAccessPolicy.canStage(uid: 502, owner: 501, exists: true))
        precondition(!RuntimeAccessPolicy.canStage(uid: 502, owner: 501, exists: false))
        for connect in [false,true] { for disconnect in [false,true] {
            precondition(RuntimeAccessPolicy.canUseManaged(action: .connect, connect: connect, disconnect: disconnect) == connect)
            precondition(RuntimeAccessPolicy.canUseManaged(action: .disconnect, connect: connect, disconnect: disconnect) == disconnect)
        }}
        print("PASS: cross-user overwrite and unknown legacy ownership denied; managed policy enforced")
    }
}
