import Foundation

enum WeatherIconAsset: String, Equatable, Hashable {
    case sun = "Property 1=01.sun-light"
    case partlyCloudy = "Property 1=05.partial-cloudy-light"
    case lightRainWithSun = "Property 1=06.rainyday-light"
    case mostlyCloudyWithSun = "Property 1=07.mostly-cloud-light"
    case cloudyNight = "Property 1=11.cloudy-night-light"
    case thunder = "Property 1=12.thunder-light"
    case thunderstorm = "Property 1=13.thunderstorm-light"
    case heavySnowfall = "Property 1=14.heavy-snowfall-light"
    case cloud = "Property 1=15.cloud-light"
    case cloudyNightAlt = "Property 1=16.cloudy-night-light"
    case cloudyNightStars = "Property 1=17.cloudy-night-stars-light"
    case heavyRain = "Property 1=18.heavy-rain-light"
    case rain = "Property 1=20.rain-light"
    case heavyWind = "Property 1=21.heavy-wind-light"
    case snow = "Property 1=22.snow-light"
    case hailstorm = "Property 1=23.hailstrom-light"
    case drizzle = "Property 1=24.drop-light"

    var assetName: String { rawValue }

    var fallbackSFSymbolName: String {
        switch self {
        case .sun:
            return "sun.max.fill"
        case .partlyCloudy, .mostlyCloudyWithSun:
            return "cloud.sun.fill"
        case .lightRainWithSun:
            return "cloud.sun.rain.fill"
        case .cloudyNight, .cloudyNightAlt, .cloudyNightStars:
            return "cloud.moon.fill"
        case .thunder:
            return "cloud.bolt.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .heavySnowfall, .snow:
            return "snow"
        case .cloud:
            return "cloud.fill"
        case .heavyRain, .rain, .drizzle:
            return "cloud.rain.fill"
        case .heavyWind:
            return "wind"
        case .hailstorm:
            return "cloud.hail.fill"
        }
    }
}
