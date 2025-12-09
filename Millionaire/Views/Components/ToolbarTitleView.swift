import SwiftUI

struct ToolbarTitleView: View {
    let index: Int
    let prize: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("ВОПРОС #\(index + 1)")
                .font(.headline)
                .foregroundColor(.white)

            Text("$\(prize)")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
        }
    }
}
