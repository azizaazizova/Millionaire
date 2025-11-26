import Foundation

enum GamePhase: Equatable {
    case notStarted
    case asking(levelIndex: Int, timeRemaining: Int)
    case answered(correct: Bool, levelIndex: Int)
    case finished(wonAmount: Int)
}
