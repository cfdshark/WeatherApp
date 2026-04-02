import Foundation

struct WeatherSnapshot: Equatable {
    let locationName: String
    let coordinate: LocationCoordinate
    let currentTemperatureCelsius: Int
    let currentFeelsLikeTemperatureCelsius: Int
    let primaryDescription: String
    let humidityPercentage: Int
    let windSpeedKilometersPerHour: Int
    let precipitationProbabilityPercentage: Int
    let primaryCondition: WeatherConditionCategory
    let primaryIcon: WeatherIconAsset
    let forecastDays: [ForecastDay]
}
