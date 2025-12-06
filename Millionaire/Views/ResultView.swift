import SwiftUI

struct ResultView: View {
    let persistence: PersistenceService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.clear.millionaireBackground()

            VStack(spacing: 24) {
                Text("Игра завершена")
                    .font(.title).bold()
                    .foregroundColor(.white)

                if let saved = persistence.load() {
                    Text("Ваш приз: $\(saved.wonAmount)")
                        .font(.title2)
                        .foregroundColor(.yellow)
                } else {
                    Text("Ваш приз: $0")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }

                Button {
                    persistence.save(nil) // сброс сохранения
                    dismiss()             // вернуться на HomeView
                } label: {
                    BrandButton(title: "На главную")
                }
            }
            .padding()
        }
    }
}
