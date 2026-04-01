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

    static func temperatureString(celsius: Int) -> String {
        "\(celsius)°"
    }
}
