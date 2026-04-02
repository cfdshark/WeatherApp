import SwiftUI

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

                Text("\(snapshot.currentTemperatureCelsius)°")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
