import Foundation

struct ForecastDay: Equatable, Identifiable {
    let date: Date
    let temperatureCelsius: Int
    let condition: WeatherConditionCategory
    let icon: WeatherIconAsset

    var id: Date { date }
}
