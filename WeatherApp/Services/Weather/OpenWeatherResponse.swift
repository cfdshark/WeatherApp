import Foundation

struct OpenWeatherResponse: Decodable {
    let list: [ForecastEntry]
    let city: City

    struct ForecastEntry: Decodable {
        let timestamp: TimeInterval
        let main: Main
        let weather: [Weather]
        let wind: Wind?
        let precipitationProbability: Double?

        enum CodingKeys: String, CodingKey {
            case timestamp = "dt"
            case main
            case weather
            case wind
            case precipitationProbability = "pop"
        }
    }

    struct Main: Decodable {
        let temperature: Double
        let feelsLikeTemperature: Double
        let minimumTemperature: Double
        let maximumTemperature: Double
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case feelsLikeTemperature = "feels_like"
            case minimumTemperature = "temp_min"
            case maximumTemperature = "temp_max"
            case humidity
        }
    }

    struct Weather: Decodable {
        let id: Int
        let main: String
        let description: String
    }

    struct Wind: Decodable {
        let speed: Double
    }

    struct City: Decodable {
        let name: String
        let timezone: Int
    }
}
