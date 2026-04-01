import Foundation

struct WeatherSnapshot: Equatable {
    let locationName: String
    let coordinate: LocationCoordinate
    let currentTemperatureCelsius: Int
    let primaryCondition: WeatherConditionCategory
    let forecastDays: [ForecastDay]
    let overlay: WeatherOverlay?
}
