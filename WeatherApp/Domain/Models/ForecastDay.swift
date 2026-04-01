import Foundation

struct ForecastDay: Equatable, Identifiable {
    let date: Date
    let temperatureCelsius: Int
    let condition: WeatherConditionCategory

    var id: Date { date }
}
