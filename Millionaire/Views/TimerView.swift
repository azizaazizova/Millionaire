import SwiftUI

struct TimerView: View {
    let seconds: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "stopwatch")
                .foregroundColor(labelColor())
                .font(.system(size: 16, weight: .semibold))

            Text(String(format: "%02d", seconds))
                .foregroundColor(labelColor())
                .font(.system(size: 18, weight: .semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundColor())
                .opacity(0.5)
        )
    }

    // 🎨 Цвет фона
    private func backgroundColor() -> Color {
        switch seconds {
        case 0...5: return Color.red.opacity(0.5)     // последние секунды — тревожный красный
        case 6...15: return Color.yellow.opacity(0.5) // середина — напряжённый жёлтый
        default: return Color.white.opacity(0.5)      // старт — спокойный белый
        }
    }

    // 🎨 Цвет текста и иконки
    private func labelColor() -> Color {
        switch seconds {
        case 0...5: return .red   // на красном фоне — белый текст
        case 6...15: return .yellow  // на жёлтом фоне — чёрный текст
        default: return .white      // на белом фоне — чёрный текст
        }
    }
}
