import Foundation

struct OpenWeatherConditionIconMapper {
    func icon(for weather: OpenWeatherResponse.Weather?) -> WeatherIconAsset {
        if let code = weather?.id, let icon = icon(for: code) {
            return icon
        }

        if let icon = heuristicIcon(main: weather?.main, description: weather?.description) {
            return icon
        }

        return .cloud
    }

    private func icon(for code: Int) -> WeatherIconAsset? {
        switch code {
        case 800:
            return .sun
        case 801:
            return .partlyCloudy
        case 802:
            return .mostlyCloudyWithSun
        case 803, 804:
            return .cloud

        case 300, 301, 310, 311, 321:
            return .drizzle
        case 302, 312, 313, 314:
            return .rain

        case 500, 520:
            return .lightRainWithSun
        case 501, 521, 531:
            return .rain
        case 502, 503, 504, 522:
            return .heavyRain
        case 511:
            return .hailstorm

        case 200, 210, 230:
            return .thunder
        case 201, 202, 211, 212, 221, 231, 232:
            return .thunderstorm

        case 600, 601, 620, 621:
            return .snow
        case 602, 622:
            return .heavySnowfall
        case 611, 612, 613, 615, 616:
            return .hailstorm

        case 701, 711, 721, 741:
            return .cloud
        case 731, 751, 761, 762, 771, 781:
            return .heavyWind

        default:
            return nil
        }
    }

    private func heuristicIcon(main: String?, description: String?) -> WeatherIconAsset? {
        let combined = "\(main ?? "") \(description ?? "")".lowercased()

        if combined.contains("thunderstorm") { return .thunderstorm }
        if combined.contains("thunder") { return .thunder }
        if combined.contains("freezing") || combined.contains("sleet") || combined.contains("hail") { return .hailstorm }
        if combined.contains("heavy snow") { return .heavySnowfall }
        if combined.contains("snow") { return .snow }
        if combined.contains("heavy rain") || combined.contains("extreme rain") || combined.contains("very heavy rain") { return .heavyRain }
        if combined.contains("drizzle") { return .drizzle }
        if combined.contains("rain") { return .rain }
        if combined.contains("tornado") || combined.contains("squall") || combined.contains("sand") || combined.contains("dust") || combined.contains("ash") {
            return .heavyWind
        }
        if combined.contains("mist") || combined.contains("smoke") || combined.contains("haze") || combined.contains("fog") || combined.contains("cloud") {
            return .cloud
        }
        if combined.contains("clear") { return .sun }

        return nil
    }
}
