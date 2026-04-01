import Foundation

struct OpenWeatherResponse: Decodable {
    let list: [ForecastEntry]
    let city: City

    struct ForecastEntry: Decodable {
        let timestamp: TimeInterval
        let main: Main
        let weather: [Weather]

        enum CodingKeys: String, CodingKey {
            case timestamp = "dt"
            case main
            case weather
        }
    }

    struct Main: Decodable {
        let temperature: Double
        let maximumTemperature: Double

        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case maximumTemperature = "temp_max"
        }
    }

    struct Weather: Decodable {
        let main: String
        let description: String
    }

    struct City: Decodable {
        let name: String
        let timezone: Int
    }
}
