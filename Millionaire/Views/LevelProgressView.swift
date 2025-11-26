import SwiftUI

struct LevelProgressView: View {
    let currentIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(PrizeLevel.all.reversed(), id: \.id) { level in
                HStack {
                    Text("\(level.id).")
                        .frame(width: 24, alignment: .leading)
                        .foregroundColor(.white)
                    Text("$\(level.amount)")
                        .bold(level.safe ? true : false)
                        .foregroundColor(color(for: level))
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func color(for level: PrizeLevel) -> Color {
        if level.id - 1 == currentIndex { return .orange }
        return level.safe ? .yellow : .white
    }
}

#Preview {
    LevelProgressView(currentIndex: 5)
}
