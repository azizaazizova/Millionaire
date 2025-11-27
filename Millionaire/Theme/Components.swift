import SwiftUI

struct BrandButton: View {
    let title: String
    var filled: Bool = true

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 56)
            .background(
                ArrowButtonShape()
                    .fill(gradient)
            )
            .overlay(
                ArrowButtonShape()
                    .stroke(Color.white, lineWidth: 2)
            )
            .contentShape(Rectangle())
            .padding(.horizontal, 24)
    }

    private var gradient: LinearGradient {
        if filled {
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.2), Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1C2A4A"), Color(hex: "#2F3F6B")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}


// Кастомная форма кнопки
struct ArrowButtonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tipWidth: CGFloat = 16
        let radius: CGFloat = 4

        path.move(to: CGPoint(x: tipWidth + radius, y: 0))
        path.addArc(center: CGPoint(x: tipWidth + radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(180),
                    clockwise: true)

        path.addLine(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: tipWidth, y: rect.height - radius))
        path.addArc(center: CGPoint(x: tipWidth + radius, y: rect.height - radius),
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(90),
                    clockwise: true)

        path.addLine(to: CGPoint(x: rect.width - tipWidth - radius, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - tipWidth - radius, y: rect.height - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(0),
                    clockwise: true)

        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width - tipWidth, y: radius))
        path.addArc(center: CGPoint(x: rect.width - tipWidth - radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(-90),
                    clockwise: true)

        path.closeSubpath()
        return path
    }
}
