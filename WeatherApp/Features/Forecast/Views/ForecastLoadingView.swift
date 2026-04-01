import SwiftUI

struct ForecastLoadingView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
