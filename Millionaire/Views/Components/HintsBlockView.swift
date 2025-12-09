import SwiftUI

struct HintsBlockView: View {
    @Binding var hintUsed: Bool
    @Binding var callUsed: Bool
    @Binding var audienceUsed: Bool
    @Binding var secondChanceUsed: Bool

    let onFiftyFifty: () -> Void
    let onCall: () -> Void
    let onAudience: () -> Void
    let onSecondChance: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            hintButton(title: "50:50", systemImage: nil, used: hintUsed) {
                onFiftyFifty()
                hintUsed = true
            }
            hintButton(title: "", systemImage: "phone.fill", used: callUsed) {
                onCall()
                callUsed = true
            }
            hintButton(title: "", systemImage: "person.3.fill", used: audienceUsed) {
                onAudience()
                audienceUsed = true
            }
            hintButton(title: "", systemImage: "heart.fill", used: secondChanceUsed) {
                onSecondChance()
                secondChanceUsed = true
            }
        }
    }

    // Универсальный рендер кнопки подсказки
    private func hintButton(title: String,
                            systemImage: String?,
                            used: Bool,
                            action: @escaping () -> Void) -> some View {
        OvalHintButton(title: title,
                       systemImage: systemImage,
                       disabled: used) {
            if !used { action() }
        }
        .foregroundColor(used ? .gray : .white) // текст/иконка серые если использована
        .opacity(used ? 0.6 : 1.0)              // приглушаем кнопку
    }
}
