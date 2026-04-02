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

                HStack(alignment: .center, spacing: 16) {
                    headerIcon

                    Text("\(snapshot.currentTemperatureCelsius)°")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
