import Foundation

struct AppContainer {
    let locationProvider: LocationProviding
    let weatherProvider: WeatherProviding
    let overlayTextProvider: OverlayTextProviding

    static func live(configuration: AppConfiguration = .load()) -> AppContainer {
        let httpClient = URLSessionHTTPClient()
        let weatherProvider = OpenWeatherService(
            apiKey: configuration.openWeatherAPIKey,
            httpClient: httpClient
        )

        let overlayProvider: OverlayTextProviding
        if let baseURL = configuration.overlayTextAPIURL {
            overlayProvider = RemoteOverlayTextProvider(baseURL: baseURL, httpClient: httpClient)
        } else {
            overlayProvider = StubOverlayTextProvider()
        }

        return AppContainer(
            locationProvider: CoreLocationProvider(),
            weatherProvider: weatherProvider,
            overlayTextProvider: overlayProvider
        )
    }
}
