import Foundation

enum Route: Hashable {
    case splash
    case home
    case game
    case result(wonAmount: Int)
}
