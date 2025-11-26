import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Image("logo") // добавь логотип в Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Кто хочет стать миллионером?")
                    .font(.title2).foregroundColor(.white)

                ProgressView()
                    .tint(.yellow)
            }
        }
        .millionaireBackground()
        .overlay(Color.black.opacity(0.3))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onFinish()
            }
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
