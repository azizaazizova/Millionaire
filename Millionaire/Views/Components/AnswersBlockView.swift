import SwiftUI

struct AnswersBlockView: View {
    let answers: [String]
    let hiddenIndices: Set<Int>
    let selectedAnswer: Int?
    let isCorrect: Bool?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(answers.indices, id: \.self) { index in
                AnswerButtonView(
                    index: index,
                    text: answers[index],
                    selected: selectedAnswer,
                    isCorrect: isCorrect,
                    action: {
                        onSelect(index)
                    }
                )
                // если индекс в hiddenIndices → делаем серым и блокируем
                .foregroundColor(hiddenIndices.contains(index) ? .gray : .white)
                .opacity(hiddenIndices.contains(index) ? 0.6 : 1.0)
                .disabled(hiddenIndices.contains(index))
            }
        }
        .padding(.bottom, 32)
    }
}
