import SwiftUI

struct QuestionHeaderView: View {
    let timeRemaining: Int
    let question: String

    var body: some View {
        VStack(spacing: 30) {
            TimerView(seconds: timeRemaining)
                .frame(width: 84, height: 64)

            Text(question)
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}
