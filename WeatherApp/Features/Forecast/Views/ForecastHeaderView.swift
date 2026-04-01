import SwiftUI

struct ForecastHeaderView: View {
    let snapshot: WeatherSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5 Day Forecast")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                Text(snapshot.locationName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(snapshot.currentTemperatureCelsius)°")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            if let overlay = snapshot.overlay {
                VStack(alignment: .leading, spacing: 6) {
                    Text(overlay.title)
                        .font(.headline.weight(.semibold))
                    Text(overlay.message)
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial.opacity(0.4), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
