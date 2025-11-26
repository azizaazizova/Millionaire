import Foundation

struct Question: Identifiable, Codable {
    let id: UUID = UUID()
    let text: String
    let options: [String]
    let correctIndex: Int
}
