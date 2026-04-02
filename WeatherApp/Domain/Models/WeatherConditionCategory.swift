import Foundation

enum WeatherConditionCategory: String, Equatable, CaseIterable, Hashable {
    case sunny
    case cloudy
    case rainy

    init(openWeatherCondition: String) {
        switch openWeatherCondition.lowercased() {
        case "clear":
            self = .sunny
        case "clouds", "mist", "smoke", "haze", "dust", "fog", "sand", "ash", "squall", "tornado":
            self = .cloudy
        case "drizzle", "rain", "thunderstorm", "snow":
            self = .rainy
        default:
            self = .cloudy
        }
    }

    var sfSymbolName: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        }
    }
}
