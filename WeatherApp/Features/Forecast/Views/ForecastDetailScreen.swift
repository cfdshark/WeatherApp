import SwiftUI
import UIKit

struct ForecastDetailScreen: View {
    let snapshot: WeatherSnapshot
    let selectedDay: ForecastDay

    var body: some View {
        ZStack {
            WeatherBackgroundView(category: selectedDay.condition)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    summaryCard

                    if comparisonDays.isEmpty == false {
                        comparisonSection
                    }

                    if selectedDay.hourlyForecasts.isEmpty == false {
                        hourlySection
                    }

                    if snapshot.forecastDays.isEmpty == false {
                        futureDaysSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label(snapshot.locationName, systemImage: "location.fill")
                    .font(.custom("Poppins-Medium", size: 18))
                    .foregroundStyle(.black.opacity(0.76))

                Spacer()

                Text(summaryTimeLabel)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.black.opacity(0.56))
            }

            VStack(spacing: 8) {
                weatherIcon(selectedDay.icon, condition: selectedDay.condition, size: 70)

                Text(ForecastPresentationFormatter.temperatureString(celsius: selectedDay.temperatureCelsius))
                    .font(.system(size: 54, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.86))

                Text(selectedDay.description)
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundStyle(.black.opacity(0.62))
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                metricRow(title: "Feels like", systemImage: "thermometer.medium", value: ForecastPresentationFormatter.temperatureString(celsius: selectedDay.feelsLikeTemperatureCelsius))
                metricRow(title: "Chance of rain", systemImage: "drop.fill", value: "\(selectedDay.precipitationProbabilityPercentage)%")
                metricRow(title: "Wind", systemImage: "wind", value: "\(selectedDay.windSpeedKilometersPerHour) km/h")
                metricRow(title: "Humidity", systemImage: "humidity.fill", value: "\(selectedDay.humidityPercentage)%")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 10)
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ForEach(comparisonDays) { day in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(ForecastPresentationFormatter.relativeDayLabel(for: day.date, relativeTo: selectedDay.date))
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundStyle(.black.opacity(0.72))

                        HStack(alignment: .center, spacing: 12) {
                            weatherIcon(day.icon, condition: day.condition, size: 34)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(ForecastPresentationFormatter.temperatureRangeString(lowCelsius: day.minTemperatureCelsius, highCelsius: day.maxTemperatureCelsius))
                                    .font(.custom("Poppins-SemiBold", size: 18))
                                    .foregroundStyle(.black.opacity(0.84))

                                Text(day.description)
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundStyle(.black.opacity(0.55))
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("24-hour forecast")
                .font(.custom("Poppins-SemiBold", size: 22))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 18) {
                    ForEach(selectedDay.hourlyForecasts) { hour in
                        VStack(spacing: 10) {
                            Text(ForecastPresentationFormatter.timeString(from: hour.date))
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundStyle(.black.opacity(0.54))

                            weatherIcon(hour.icon, condition: hour.condition, size: 30)

                            Text(ForecastPresentationFormatter.temperatureString(celsius: hour.temperatureCelsius))
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundStyle(.black.opacity(0.84))
                        }
                        .frame(width: 72)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var futureDaysSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(snapshot.forecastDays.count)-day forecast")
                .font(.custom("Poppins-SemiBold", size: 22))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(snapshot.forecastDays) { day in
                    HStack(spacing: 16) {
                        Text(ForecastPresentationFormatter.shortDateString(from: day.date))
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundStyle(.black.opacity(0.84))

                        Spacer()

                        weatherIcon(day.icon, condition: day.condition, size: 26)

                        Text(ForecastPresentationFormatter.slashTemperatureRangeString(lowCelsius: day.minTemperatureCelsius, highCelsius: day.maxTemperatureCelsius))
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundStyle(.black.opacity(day.id == selectedDay.id ? 0.88 : 0.62))
                    }
                    .padding(.vertical, 14)

                    if day.id != snapshot.forecastDays.last?.id {
                        Divider()
                            .overlay(.black.opacity(0.08))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private var comparisonDays: [ForecastDay] {
        guard let selectedIndex = snapshot.forecastDays.firstIndex(where: { $0.id == selectedDay.id }) else {
            return []
        }

        return Array(snapshot.forecastDays.dropFirst(selectedIndex + 1).prefix(2))
    }

    private var summaryTimeLabel: String {
        ForecastPresentationFormatter.summaryTimeLabel(for: selectedDay.date, hourlyForecasts: selectedDay.hourlyForecasts)
    }

    private func metricRow(title: String, systemImage: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.black.opacity(0.54))
                .frame(width: 28)

            Text(title)
                .font(.custom("Poppins-Regular", size: 18))
                .foregroundStyle(.black.opacity(0.64))

            Spacer()

            Text(value)
                .font(.custom("Poppins-Medium", size: 18))
                .foregroundStyle(.black.opacity(0.84))
        }
    }

    @ViewBuilder
    private func weatherIcon(_ icon: WeatherIconAsset, condition: WeatherConditionCategory, size: CGFloat) -> some View {
        if UIImage(named: icon.assetName) != nil {
            Image(icon.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: icon.fallbackSFSymbolName)
                .font(.system(size: size * 0.72))
                .foregroundStyle(iconColor(for: condition))
        }
    }

    private func iconColor(for condition: WeatherConditionCategory) -> Color {
        switch condition {
        case .sunny:
            return .yellow.opacity(0.92)
        case .cloudy:
            return .gray.opacity(0.82)
        case .rainy:
            return .blue.opacity(0.88)
        }
    }
}
