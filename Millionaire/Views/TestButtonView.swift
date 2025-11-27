import SwiftUI

struct TestButtonView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink(destination: Text("Цель")) {
                    BrandButton(title: "Тестовая кнопка")
                }
            }
        }
    }
}
