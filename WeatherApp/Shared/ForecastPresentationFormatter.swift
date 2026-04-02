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

    static func shortDateString(
        from date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }

    static func timeString(
        from date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func relativeDayLabel(
        for targetDate: Date,
        relativeTo selectedDate: Date,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        var calendar = calendar
        calendar.timeZone = timeZone

        if calendar.isDateInToday(selectedDate),
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate)),
           calendar.isDate(targetDate, inSameDayAs: tomorrow) {
            return "Tomorrow"
        }

        return shortDateString(from: targetDate, locale: locale, timeZone: timeZone)
    }

    static func summaryTimeLabel(
        for selectedDate: Date,
        hourlyForecasts: [ForecastHour],
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        var calendar = calendar
        calendar.timeZone = timeZone

        if calendar.isDateInToday(selectedDate) {
            return "Now"
        }

        guard let firstHour = hourlyForecasts.first else {
            return timeString(from: selectedDate, locale: locale, timeZone: timeZone)
        }

        return timeString(from: firstHour.date, locale: locale, timeZone: timeZone)
    }

    static func temperatureString(
        celsius: Int,
        unitPreference: TemperatureUnitPreference = TemperatureUnitPreference()
    ) -> String {
        let displayValue = unitPreference.displayValue(forCelsius: celsius)
        return "\(displayValue)\(unitPreference.unitSuffix)"
    }

    static func slashTemperatureRangeString(
        lowCelsius: Int,
        highCelsius: Int,
        unitPreference: TemperatureUnitPreference = TemperatureUnitPreference()
    ) -> String {
        let low = unitPreference.displayValue(forCelsius: lowCelsius)
        let high = unitPreference.displayValue(forCelsius: highCelsius)
        let suffix = unitPreference.unitSuffix
        return "\(low)\(suffix)/\(high)\(suffix)"
    }

    static func temperatureRangeString(
        lowCelsius: Int,
        highCelsius: Int,
        unitPreference: TemperatureUnitPreference = TemperatureUnitPreference()
    ) -> String {
        let low = unitPreference.displayValue(forCelsius: lowCelsius)
        let high = unitPreference.displayValue(forCelsius: highCelsius)
        let suffix = unitPreference.unitSuffix
        return "\(low)~\(high)\(suffix)"
    }
}
