import SwiftUI

struct ForecastRowView: View {
    let day: ForecastDay

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text(ForecastPresentationFormatter.weekdayString(from: day.date))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.88))

                Image(systemName: day.condition.sfSymbolName)
                    .font(.system(size: 28))
                    .foregroundStyle(iconColor)
            }

            Spacer()

            Text(ForecastPresentationFormatter.temperatureString(celsius: day.temperatureCelsius))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.9))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
    }

    private var iconColor: Color {
        switch day.condition {
        case .sunny:
            return .yellow.opacity(0.95)
        case .cloudy:
            return .gray.opacity(0.9)
        case .rainy:
            return .blue.opacity(0.95)
        }
    }
}
