import SwiftUI

struct TimerView: View {
    let seconds: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(timerColor())
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.purple, lineWidth: 2)
                )

            HStack {
                Image(systemName: "stopwatch")
                    .foregroundColor(iconColor())
                Text(String(format: "%02d", seconds))
                    .font(.headline)
                    .foregroundColor(iconColor())
            }
        }
    }

    private func timerColor() -> Color {
        switch seconds {
        case 0...5: return .red
        case 6...15: return .orange
        default: return Color(hex: "#1C2A4A")
        }
    }

    private func iconColor() -> Color {
        switch seconds {
        case 0...5: return .white
        case 6...15: return .red
        default: return .orange
        }
    }
}
