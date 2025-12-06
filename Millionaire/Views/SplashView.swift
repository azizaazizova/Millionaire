import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Фон через модификатор
            Color.clear.millionaireBackground()

            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 260)

                Text("Кто хочет стать миллионером?")
                    .font(.title).bold()
                    .foregroundColor(.white)
            }
        }
    }
}
