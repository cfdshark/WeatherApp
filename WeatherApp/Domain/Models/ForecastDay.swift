import Foundation

struct ForecastHour: Equatable, Hashable, Identifiable {
    let date: Date
    let temperatureCelsius: Int
    let feelsLikeTemperatureCelsius: Int
    let humidityPercentage: Int
    let windSpeedKilometersPerHour: Int
    let precipitationProbabilityPercentage: Int
    let description: String
    let condition: WeatherConditionCategory
    let icon: WeatherIconAsset

    var id: Date { date }
}

struct ForecastDay: Equatable, Hashable, Identifiable {
    let date: Date
    let temperatureCelsius: Int
    let feelsLikeTemperatureCelsius: Int
    let minTemperatureCelsius: Int
    let maxTemperatureCelsius: Int
    let description: String
    let humidityPercentage: Int
    let windSpeedKilometersPerHour: Int
    let precipitationProbabilityPercentage: Int
    let condition: WeatherConditionCategory
    let icon: WeatherIconAsset
    let hourlyForecasts: [ForecastHour]

    var id: Date { date }
}
