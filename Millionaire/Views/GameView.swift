import SwiftUI

struct GameView: View {
    @ObservedObject var coordinator: AppCoordinator
    let persistence: PersistenceService
    @StateObject private var vm: GameViewModel

    init(coordinator: AppCoordinator, persistence: PersistenceService) {
        self.coordinator = coordinator
        self.persistence = persistence
        let restored = persistence.load()
        _vm = StateObject(wrappedValue: GameViewModel(
            questionService: QuestionService(),
            persistence: persistence,
            restored: restored
        ))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                header
                questionBlock
                optionsBlock
                LevelProgressView(currentIndex: vm.currentLevelIndex())
                Spacer()
            }
            .padding()
        }
        .millionaireBackground()
        .overlay(Color.black.opacity(0.3))
        .onChange(of: vm.phase) { _, phase in
            if case .finished(let amount) = phase {
                coordinator.finishGame(wonAmount: amount)
            }
        }
        .navigationTitle("Игра")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Text("Приз: $\(vm.currentPrize())").font(.headline).foregroundColor(.yellow)
            Spacer()
            if case .asking(_, let time) = vm.phase {
                Text("Время: \(time)s").font(.headline).foregroundColor(.red)
            }
        }
    }

    private var questionBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.question.text).font(.title3).bold().foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var optionsBlock: some View {
        VStack(spacing: 10) {
            ForEach(vm.question.options.indices, id: \.self) { i in
                Button {
                    vm.selectAnswer(i)
                } label: {
                    HStack {
                        Text(optionPrefix(i))
                            .font(.headline).bold()
                        Text(vm.question.options[i])
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(optionBackground(i))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isOptionEnabled)
            }
        }
    }

    private var isOptionEnabled: Bool {
        if case .asking = vm.phase { return true }
        return false
    }

    private func optionPrefix(_ i: Int) -> String {
        ["A", "B", "C", "D"][i]
    }

    private func optionBackground(_ i: Int) -> Color {
        if let selected = vm.selectedIndex, selected == i {
            if case .answered(let correct, _) = vm.phase {
                return correct ? .green : .red
            }
            return .blue
        }
        if let highlight = vm.highlightCorrectIndex, highlight == i {
            return .green
        }
        return .indigo
    }
}

#Preview {
    GameView(coordinator: AppCoordinator(), persistence: PersistenceService())
}
