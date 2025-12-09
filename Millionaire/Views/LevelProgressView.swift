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
    
    private static let background = MillionaireBackground()
    
    var body: some View {
        ZStack {
            LevelProgressView.background.ignoresSafeArea()
            
            // Кнопка CashOut
            VStack {
                HStack {
                    Button(action: onCashOut) {
                        Image("withdrawal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(10)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Лестница уровней
            VStack(spacing: 0) {
                Spacer(minLength: 80)
                
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
                    .frame(maxWidth: 300, maxHeight: 56)
                    .background(
                        ArrowButtonShape()
                            .fill(buttonGradient(for: index))
                            .animation(.easeInOut(duration: 0.5), value: currentLevel) 
                    )
                    .overlay(
                        ArrowButtonShape()
                            .stroke(Color.white, lineWidth: 2)
                    )
                }
                
                Spacer()
            }
            
            // Лого
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .offset(y: 18)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func buttonGradient(for index: Int) -> LinearGradient {
        if index == currentLevel {
            return AppGradient.greenMint.linear // активный уровень
        } else if guaranteedIndices.contains(index) {
            return AppGradient.blueHighlight.linear
        } else {
            return AppGradient.darkBlue.linear
        }
    }
}

