import SwiftUI

struct LevelProgressView: View {
    let levels: [String] = [
        "$100", "$200", "$300", "$500",
        "$1,000", "$2,000", "$4,000", "$8,000",
        "$16,000", "$32,000", "$64,000", "$125,000",
        "$250,000", "$500,000", "$1,000,000"
    ]

    let currentLevel: Int
    let onCashOut: () -> Void

    let guaranteedIndices: Set<Int> = [4, 9, 14]

    var body: some View {
        ZStack {
            Color.clear.millionaireBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                ForEach(levels.indices.reversed(), id: \.self) { index in
                    HStack {
                        Text("Вопрос \(index + 1)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(levels[index])
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, maxHeight: 56)
                    .background(
                        ArrowButtonShape()
                            .fill(buttonGradient(for: index))
                    )
                    .overlay(
                        ArrowButtonShape()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                }

                Spacer()

                Button(action: onCashOut) {
                    Text("Забрать деньги")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.8))
                        )
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func buttonGradient(for index: Int) -> LinearGradient {
        if index == currentLevel {
            return AppGradient.yellowOrange.linear
        } else if guaranteedIndices.contains(index) {
            return AppGradient.darkBlue.linear
        } else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
