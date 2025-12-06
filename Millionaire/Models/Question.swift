import Foundation

struct Question: Codable, Identifiable {
    let id: Int
    let question: String
    let answers: [String]
    let correctIndex: Int
    let prize: Int
}
