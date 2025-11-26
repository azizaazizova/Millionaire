import SwiftUI

struct BrandButton: View {
    let title: String
    let action: () -> Void
    var filled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(filled ? Color.yellow : Color.clear)
                .foregroundColor(filled ? .black : .yellow)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow, lineWidth: filled ? 0 : 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
