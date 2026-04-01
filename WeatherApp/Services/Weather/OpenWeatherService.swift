import Foundation

enum WeatherServiceError: Error, Equatable {
    case missingAPIKey
    case invalidURL
    case decodingFailed
    case transport(message: String)

    var userMessage: String {
        switch self {
        case .missingAPIKey:
            return "Add a valid OpenWeather API key to the app configuration before running the app."
        case .invalidURL:
            return "The weather request could not be created."
        case .decodingFailed:
            return "Weather data was returned in an unexpected format."
        case .transport(let message):
            return message
        }
    }
}

struct OpenWeatherService: WeatherProviding {
    private let apiKey: String
    private let httpClient: HTTPClient
    private let mapper: OpenWeatherForecastMapper

    init(
        apiKey: String,
        httpClient: HTTPClient,
        mapper: OpenWeatherForecastMapper = OpenWeatherForecastMapper()
    ) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func fetchForecast(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot {
        guard apiKey.isEmpty == false, apiKey != "YOUR_API_KEY" else {
            throw WeatherServiceError.missingAPIKey
        }

        guard var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast") else {
            throw WeatherServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components.url else {
            throw WeatherServiceError.invalidURL
        }

        let request = URLRequest(url: url)

        do {
            let (data, _) = try await httpClient.data(for: request)
            let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            return mapper.map(response: response, coordinate: coordinate)
        } catch is DecodingError {
            throw WeatherServiceError.decodingFailed
        } catch let error as NetworkError {
            throw WeatherServiceError.transport(message: transportMessage(for: error))
        } catch {
            throw WeatherServiceError.transport(message: "The weather request failed. Please try again.")
        }
    }

    private func transportMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidResponse:
            return "The weather service returned an invalid response."
        case .requestFailed(let statusCode):
            return "The weather service failed with status code \(statusCode)."
        }
    }
}
