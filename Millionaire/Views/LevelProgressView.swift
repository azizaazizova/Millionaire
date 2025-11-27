import SwiftUI

struct LevelProgressView: View {
    // Пример данных — список уровней и призов
    let levels: [String] = [
        "$100", "$200", "$300", "$500",
        "$1,000", "$2,000", "$4,000", "$8,000",
        "$16,000", "$32,000", "$64,000", "$125,000",
        "$250,000", "$500,000", "$1,000,000"
    ]

    // Текущий уровень игрока
    let currentLevel: Int

    var body: some View {
        ZStack {
            // Фон через модификатор
            Color.clear.millionaireBackground()

            VStack(spacing: 12) {
                Text("Прогресс игры")
                    .font(.title2).bold()
                    .foregroundColor(.yellow)

                ForEach(levels.indices.reversed(), id: \.self) { index in
                    HStack {
                        Text(levels[index])
                            .font(.headline)
                            .foregroundColor(index == currentLevel ? .black : .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(index == currentLevel ? Color.yellow : Color.clear)
                            )
                    }
                }
            }
            .padding()
        }
    }
}


#Preview {
    LevelProgressView(currentLevel: 5)
}
