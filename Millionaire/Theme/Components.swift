import SwiftUI

// MARK: - Градиенты приложения

enum AppGradient {
    case yellowOrange //кнопки
    case greenMint //правильный ответ
    case redGold // неправильный ответ
    case darkBlue //дефолт
    case blueHighlight   // для несгораемых

    var linear: LinearGradient {
        switch self {
        case .yellowOrange:
            return LinearGradient(
                colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .greenMint:
            return LinearGradient(
                colors: [Color(hex: "#3B8E14"), Color(hex: "#266608")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .redGold:
            return LinearGradient(
                colors: [Color(hex: "#B4411C"), Color(hex: "#832102")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .darkBlue:
            return LinearGradient(
                colors: [Color(hex: "#1C2A4A"), Color(hex: "#2F3F6B")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .blueHighlight:
            return LinearGradient(
                colors: [Color(hex: "#25B1FF"), Color(hex: "#083C66")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}


// MARK: - Форма стрелочной кнопки
struct ArrowButtonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        let cut = h * 0.35

        path.move(to: CGPoint(x: cut, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cut, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: h / 2))
        path.addLine(to: CGPoint(x: rect.width - cut, y: h))
        path.addLine(to: CGPoint(x: cut, y: h))
        path.addLine(to: CGPoint(x: 0, y: h / 2))
        path.closeSubpath()

        return path
    }
}

// MARK: - Стрелочная кнопка
struct BrandButton: View {
    let title: String
    var gradient: LinearGradient? = nil

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 56)
            .background(
                ArrowButtonShape()
                    .fill(gradient ?? AppGradient.yellowOrange.linear)
            )
            .overlay(
                ArrowButtonShape()
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal, 24)
    }
}

// MARK: - Овальная кнопка подсказки
struct OvalHintButton: View {
    let title: String
    var systemImage: String? = nil
    var disabled: Bool = false
    var gradient: LinearGradient = AppGradient.darkBlue.linear
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 84, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(gradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white, lineWidth: 2)
            )
            .opacity(disabled ? 0.5 : 1.0)
        }
        .disabled(disabled)
    }
}

// MARK: - Кнопка ответа
struct AnswerButtonView: View {
    let index: Int
    let text: String
    let selected: Int?
    let isCorrect: Bool?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BrandButton(
                title: "\(letter(for: index)): \(text)",
                gradient: buttonGradient
            )
        }
    }

    private var buttonGradient: LinearGradient {
        if let selected = selected, selected == index {
            if isCorrect == true {
                return AppGradient.greenMint.linear   // правильный → зелёный
            } else if isCorrect == false {
                return AppGradient.redGold.linear     // неправильный → красно‑золотой
            }
        }
        return AppGradient.darkBlue.linear           // по умолчанию → тёмно‑синий
    }

    private func letter(for index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }
}
