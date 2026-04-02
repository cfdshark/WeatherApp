import Foundation

struct OpenWeatherForecastMapper {
    func map(response: OpenWeatherResponse, coordinate: LocationCoordinate) -> WeatherSnapshot {
        let timezone = TimeZone(secondsFromGMT: response.city.timezone) ?? .current
        let entries = response.list.map { entry in
            MappedEntry(
                date: Date(timeIntervalSince1970: entry.timestamp),
                temperature: Int(entry.main.temperature.rounded()),
                maxTemperature: Int(entry.main.maximumTemperature.rounded()),
                condition: WeatherConditionCategory(openWeatherCondition: entry.weather.first?.main ?? "")
            )
        }

        let forecastDays = dailyForecasts(from: entries, timezone: timezone)
        let currentEntry = entries.first

        return WeatherSnapshot(
            locationName: response.city.name,
            coordinate: coordinate,
            currentTemperatureCelsius: currentEntry?.temperature ?? 0,
            primaryCondition: currentEntry?.condition ?? .cloudy,
            forecastDays: forecastDays
        )
    }

    private func dailyForecasts(from entries: [MappedEntry], timezone: TimeZone) -> [ForecastDay] {
        var grouped: [DayKey: [MappedEntry]] = [:]
        let calendar = Calendar(identifier: .gregorian)

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
                let dominantCondition = value
                    .reduce(into: [WeatherConditionCategory: Int]()) { counts, entry in
                        counts[entry.condition, default: 0] += 1
                    }
                    .max { $0.value < $1.value }?
                    .key ?? .cloudy

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
                    temperatureCelsius: highestTemperature,
                    condition: dominantCondition
                )
            }
    }
}

private struct MappedEntry {
    let date: Date
    let temperature: Int
    let maxTemperature: Int
    let condition: WeatherConditionCategory
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
