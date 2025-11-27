import SwiftUI

// MARK: - HEX → Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255
        g = Double((int >> 8) & 0xFF) / 255
        b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Модель случайного пятна
struct RandomSpot: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let opacity: Double

    init() {
        x = CGFloat.random(in: 0...1)       // позиция по ширине
        y = CGFloat.random(in: 0...1)       // позиция по высоте
        radius = CGFloat.random(in: 150...350) // размер пятна
        opacity = Double.random(in: 0.3...0.6) // прозрачность
    }
}

// MARK: - Фон с градиентом и мягкими пятнами
extension View {
    func millionaireBackground(spots: [RandomSpot] = (0..<6).map { _ in RandomSpot() }) -> some View {
        self
            .background(
                GeometryReader { geo in
                    ZStack {
                        // Градиентный фон
                        LinearGradient(
                            colors: [Color(hex: "#1C2A4A"), Color(hex: "#2F3F6B")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

                        // Мягкие чёрные пятна
                        ForEach(spots) { spot in
                            Circle()
                                .fill(Color.black.opacity(spot.opacity))
                                .frame(width: spot.radius, height: spot.radius)
                                .blur(radius: 60)
                                .position(
                                    x: spot.x * geo.size.width,
                                    y: spot.y * geo.size.height
                                )
                        }
                    }
                    .allowsHitTesting(false) //чтобы фон не блокировал клики
                }
            )
    }
}
