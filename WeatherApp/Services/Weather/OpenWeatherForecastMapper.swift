import Foundation

struct OpenWeatherForecastMapper {
    private let iconMapper = OpenWeatherConditionIconMapper()

    func map(response: OpenWeatherResponse, coordinate: LocationCoordinate) -> WeatherSnapshot {
        let timezone = TimeZone(secondsFromGMT: response.city.timezone) ?? .current
        let entries = response.list.map { entry in
            let primaryWeather = entry.weather.first
            return MappedEntry(
                date: Date(timeIntervalSince1970: entry.timestamp),
                temperature: Int(entry.main.temperature.rounded()),
                feelsLikeTemperature: Int(entry.main.feelsLikeTemperature.rounded()),
                minTemperature: Int(entry.main.minimumTemperature.rounded()),
                maxTemperature: Int(entry.main.maximumTemperature.rounded()),
                description: formattedDescription(from: primaryWeather),
                humidity: entry.main.humidity,
                windSpeedKilometersPerHour: Int(((entry.wind?.speed ?? 0) * 3.6).rounded()),
                precipitationProbabilityPercentage: Int(((entry.precipitationProbability ?? 0) * 100).rounded()),
                condition: WeatherConditionCategory(openWeatherCondition: primaryWeather?.main ?? ""),
                icon: iconMapper.icon(for: primaryWeather)
            )
        }

        let forecastDays = dailyForecasts(from: entries, timezone: timezone)
        let currentEntry = entries.first

        return WeatherSnapshot(
            locationName: response.city.name,
            coordinate: coordinate,
            currentTemperatureCelsius: currentEntry?.temperature ?? 0,
            currentFeelsLikeTemperatureCelsius: currentEntry?.feelsLikeTemperature ?? 0,
            primaryDescription: currentEntry?.description ?? "",
            humidityPercentage: currentEntry?.humidity ?? 0,
            windSpeedKilometersPerHour: currentEntry?.windSpeedKilometersPerHour ?? 0,
            precipitationProbabilityPercentage: currentEntry?.precipitationProbabilityPercentage ?? 0,
            primaryCondition: currentEntry?.condition ?? .cloudy,
            primaryIcon: currentEntry?.icon ?? .cloud,
            forecastDays: forecastDays
        )
    }

    private func dailyForecasts(from entries: [MappedEntry], timezone: TimeZone) -> [ForecastDay] {
        var grouped: [DayKey: [MappedEntry]] = [:]
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone

        for entry in entries {
            var components = calendar.dateComponents(in: timezone, from: entry.date)
            components.hour = 0
            components.minute = 0
            components.second = 0
            let key = DayKey(
                year: components.year ?? 0,
                month: components.month ?? 0,
                day: components.day ?? 0
            )
            grouped[key, default: []].append(entry)
        }

        return grouped
            .sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            .prefix(5)
            .compactMap { key, value in
                let highestTemperature = value.map(\.maxTemperature).max() ?? 0
                let lowestTemperature = value.map(\.minTemperature).min() ?? 0
                let dominantCondition = value
                    .reduce(into: [WeatherConditionCategory: Int]()) { counts, entry in
                        counts[entry.condition, default: 0] += 1
                    }
                    .max { $0.value < $1.value }?
                    .key ?? .cloudy
                let displayEntry = representativeEntry(for: value, dominantCondition: dominantCondition, calendar: calendar)

                var dateComponents = DateComponents()
                dateComponents.timeZone = timezone
                dateComponents.year = key.year
                dateComponents.month = key.month
                dateComponents.day = key.day

                guard let date = calendar.date(from: dateComponents) else {
                    return nil
                }

                return ForecastDay(
                    date: date,
                    temperatureCelsius: displayEntry?.temperature ?? highestTemperature,
                    feelsLikeTemperatureCelsius: displayEntry?.feelsLikeTemperature ?? highestTemperature,
                    minTemperatureCelsius: lowestTemperature,
                    maxTemperatureCelsius: highestTemperature,
                    description: displayEntry?.description ?? formattedDescription(from: nil),
                    humidityPercentage: displayEntry?.humidity ?? 0,
                    windSpeedKilometersPerHour: displayEntry?.windSpeedKilometersPerHour ?? 0,
                    precipitationProbabilityPercentage: displayEntry?.precipitationProbabilityPercentage ?? 0,
                    condition: dominantCondition,
                    icon: displayEntry?.icon ?? .cloud,
                    hourlyForecasts: value.map {
                        ForecastHour(
                            date: $0.date,
                            temperatureCelsius: $0.temperature,
                            feelsLikeTemperatureCelsius: $0.feelsLikeTemperature,
                            humidityPercentage: $0.humidity,
                            windSpeedKilometersPerHour: $0.windSpeedKilometersPerHour,
                            precipitationProbabilityPercentage: $0.precipitationProbabilityPercentage,
                            description: $0.description,
                            condition: $0.condition,
                            icon: $0.icon
                        )
                    }
                )
            }
    }

    private func representativeEntry(
        for entries: [MappedEntry],
        dominantCondition: WeatherConditionCategory,
        calendar: Calendar
    ) -> MappedEntry? {
        entries
            .filter { $0.condition == dominantCondition }
            .min {
                let lhsDistance = abs((calendar.component(.hour, from: $0.date) * 60) - 720)
                let rhsDistance = abs((calendar.component(.hour, from: $1.date) * 60) - 720)
                return lhsDistance < rhsDistance
            } ?? entries.first
    }

    private func formattedDescription(from weather: OpenWeatherResponse.Weather?) -> String {
        let source = (weather?.description.isEmpty == false ? weather?.description : weather?.main) ?? ""
        return source.localizedCapitalized
    }
}

private struct MappedEntry {
    let date: Date
    let temperature: Int
    let feelsLikeTemperature: Int
    let minTemperature: Int
    let maxTemperature: Int
    let description: String
    let humidity: Int
    let windSpeedKilometersPerHour: Int
    let precipitationProbabilityPercentage: Int
    let condition: WeatherConditionCategory
    let icon: WeatherIconAsset
}

private struct DayKey: Comparable, Hashable {
    let year: Int
    let month: Int
    let day: Int

    static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}
