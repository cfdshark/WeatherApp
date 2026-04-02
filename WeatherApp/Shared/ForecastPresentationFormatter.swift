import Foundation

enum ForecastPresentationFormatter {
    static func weekdayString(
        from date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    static func temperatureString(
        celsius: Int,
        unitPreference: TemperatureUnitPreference = TemperatureUnitPreference()
    ) -> String {
        let displayValue = unitPreference.displayValue(forCelsius: celsius)
        return "\(displayValue)\(unitPreference.unitSuffix)"
    }
}
