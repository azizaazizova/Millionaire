import Foundation

struct PrizeLevel: Identifiable, Codable {
    let id: Int
    let amount: Int
    let safe: Bool
}

extension PrizeLevel {
    static let all: [PrizeLevel] = [
        PrizeLevel(id: 1, amount: 100, safe: false),
        PrizeLevel(id: 2, amount: 200, safe: false),
        PrizeLevel(id: 3, amount: 300, safe: false),
        PrizeLevel(id: 4, amount: 500, safe: false),
        PrizeLevel(id: 5, amount: 1_000, safe: true),
        PrizeLevel(id: 6, amount: 2_000, safe: false),
        PrizeLevel(id: 7, amount: 4_000, safe: false),
        PrizeLevel(id: 8, amount: 8_000, safe: false),
        PrizeLevel(id: 9, amount: 16_000, safe: true),
        PrizeLevel(id: 10, amount: 32_000, safe: false),
        PrizeLevel(id: 11, amount: 64_000, safe: false),
        PrizeLevel(id: 12, amount: 125_000, safe: false),
        PrizeLevel(id: 13, amount: 250_000, safe: false),
        PrizeLevel(id: 14, amount: 500_000, safe: false),
        PrizeLevel(id: 15, amount: 1_000_000, safe: true),
    ]
}
