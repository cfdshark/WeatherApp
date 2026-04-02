import Foundation

struct AppContainer {
    let locationProvider: LocationProviding
    let weatherProvider: WeatherProviding

    static func live(configuration: AppConfiguration = .load()) -> AppContainer {
        let httpClient = URLSessionHTTPClient()
        let weatherProvider = OpenWeatherService(
            apiKey: configuration.openWeatherAPIKey,
            httpClient: httpClient
        )

        return AppContainer(
            locationProvider: CoreLocationProvider(),
            weatherProvider: weatherProvider
        )
    }
}
