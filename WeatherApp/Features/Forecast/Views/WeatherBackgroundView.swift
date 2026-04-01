import SwiftUI

struct WeatherBackgroundView: View {
    let category: WeatherConditionCategory

    var body: some View {
        ZStack {
            Image(WeatherTheme.backgroundAssetName(for: category))
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.12),
                    .black.opacity(0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}
