import Foundation

enum TemperatureUnitPreference: Equatable {
    case celsius
    case fahrenheit

    init(locale: Locale = .autoupdatingCurrent) {
        let preferredUnit = UnitTemperature(forLocale: locale)

        switch preferredUnit {
        case UnitTemperature.fahrenheit:
            self = .fahrenheit
        default:
            self = .celsius
        }
    }

    func displayValue(forCelsius celsius: Int) -> Int {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            let measurement = Measurement(value: Double(celsius), unit: UnitTemperature.celsius)
            return Int(measurement.converted(to: .fahrenheit).value.rounded())
        }
    }

    var unitSuffix: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}
