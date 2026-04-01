import SwiftUI

@main
struct WeatherAppApp: App {
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            ForecastScreen(
                viewModel: ForecastScreenViewModel(
                    locationProvider: container.locationProvider,
                    weatherProvider: container.weatherProvider,
                    overlayTextProvider: container.overlayTextProvider
                )
            )
        }
    }
}
