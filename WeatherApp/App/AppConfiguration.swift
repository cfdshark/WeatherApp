import Foundation

struct AppConfiguration {
    let openWeatherAPIKey: String

    static func load() -> AppConfiguration {
        return AppConfiguration(openWeatherAPIKey: "2d86ff63cd175eb025634694495e1b1b")
    }
}
