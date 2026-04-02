import SwiftUI
import UIKit

struct ForecastHeaderView: View {
    let snapshot: WeatherSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5 Day Forecast")
                .font(.custom("Poppins-Bold", size: 18))
                .kerning(0)
                .lineSpacing(10)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                Text(snapshot.locationName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                if snapshot.primaryDescription.isEmpty == false {
                    Text(snapshot.primaryDescription)
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(spacing: 12) {
                    metricLabel("Wind", value: "\(snapshot.windSpeedKilometersPerHour) km/h")
                    metricLabel("Humidity", value: "\(snapshot.humidityPercentage)%")
                    metricLabel("Precip", value: "\(snapshot.precipitationProbabilityPercentage)%")
                }

                HStack(alignment: .center, spacing: 16) {
                    headerIcon

                    Text(
                        ForecastPresentationFormatter.temperatureString(
                            celsius: snapshot.currentTemperatureCelsius
                        )
                    )
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricLabel(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.custom("Poppins-SemiBold", size: 10))
                .foregroundStyle(.white.opacity(0.72))

            Text(value)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var headerIcon: some View {
        if UIImage(named: snapshot.primaryIcon.assetName) != nil {
            Image(snapshot.primaryIcon.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
        } else {
            Image(systemName: snapshot.primaryIcon.fallbackSFSymbolName)
                .font(.system(size: 42))
                .foregroundStyle(.white)
        }
    }
}
