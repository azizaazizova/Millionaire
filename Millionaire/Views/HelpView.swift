import SwiftUI

struct HelpView: View {
    var body: some View {
        ZStack {
            // Фон через модификатор
            Color.clear.millionaireBackground()

            ScrollView {
                VStack(spacing: 16) {
                    Text("Правила игры")
                        .font(.title2).bold()
                        .foregroundColor(.yellow)

                    Text("""
                    • Выберите правильный ответ из четырёх вариантов.
                    • Каждый вопрос увеличивает ваш приз.
                    • Вы можете использовать подсказки: 50/50, звонок другу, помощь зала.
                    • Неправильный ответ завершает игру.
                    """)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                }
                .padding()
            }
        }
        .navigationTitle("Помощь")
        .navigationBarTitleDisplayMode(.inline)
    }
}
