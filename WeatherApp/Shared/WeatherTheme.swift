import Foundation

enum WeatherTheme {
    static func backgroundAssetName(for category: WeatherConditionCategory) -> String {
        switch category {
        case .sunny:
            return "Sunny"
        case .cloudy:
            return "Cloudy"
        case .rainy:
            return "Rainy"
        }
    }
}
