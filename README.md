# WeatherApp

WeatherApp is a SwiftUI weather client that fetches a 5-day forecast from OpenWeather using the user's current location, then displays a weather-aware background and forecast UI. The codebase is intentionally split into small views and focused services instead of a single monolithic screen.

## Conventions And Architecture

- Architecture: MVVM with feature-oriented folders and protocol-backed services.
- UI framework: SwiftUI only for app presentation. No functional UIKit screens are introduced.
- Networking: `URLSession` + `Codable`; no third-party HTTP or JSON libraries.
- State management: `ObservableObject` + `@Published` in the feature view model.
- Dependency direction: Views depend on view models, view models depend on protocols, services depend on infrastructure helpers, and domain models stay framework-light.
- Scope: one application target and one unit-test target.

## Project Structure

```text
WeatherApp/
  App/
  Domain/Models/
  Features/Forecast/ViewModels/
  Features/Forecast/Views/
  Services/Location/
  Services/Networking/
  Services/Weather/
  Shared/
WeatherAppTests/
AppStore Screenshots/
docs/
```

See [docs/Architecture.md](/Users/blessingmabunda/Documents/WeatherApp/docs/Architecture.md) for the detailed architecture breakdown.

## App Store Screenshots

App Store screenshots were generated with [appscreenshot.xyz](https://appscreenshot.xyz/) and are saved in the [AppStore Screenshots](/Users/blessingmabunda/Documents/WeatherApp/AppStore%20Screenshots) folder.

## App Demo Video

The project also includes an app demo video saved in the [AppDemoVid](/Users/blessingmabunda/Documents/WeatherApp/AppDemoVid) folder.

## Third-Party Dependencies

No third-party dependencies are currently used.

- OpenWeather is used as an external HTTP API, not as a bundled SDK.
- If cross-cutting tooling is added later, it must stay limited to concerns such as linting, logging, or CI support.

## Weather Presentation Mapping

The app now uses a two-layer weather presentation model:

- **Background images** stay intentionally coarse and unchanged.
- **Weather icons** are now specific and are mapped from OpenWeather condition data into the provided bundled asset set.

This distinction is important:

- The background is meant to communicate the overall feel of the current weather using only three states:
  - `sunny`
  - `cloudy`
  - `rainy`
- The iconography is meant to communicate the more specific weather condition returned by OpenWeather, such as:
  - clear sky
  - light rain
  - heavy rain
  - thunderstorm
  - snow
  - fog
  - wind-driven conditions

### Background Image Logic

Background selection has **not** changed.

The app still maps OpenWeather's broad `weather.main` field into the existing app-owned category enum:

- `Clear` -> `sunny`
- `Clouds`, `Mist`, `Smoke`, `Haze`, `Dust`, `Fog`, `Sand`, `Ash`, `Squall`, `Tornado` -> `cloudy`
- `Drizzle`, `Rain`, `Thunderstorm`, `Snow` -> `rainy`
- anything unknown defaults to `cloudy`

That category is then used by `WeatherTheme` to select one of the three existing background assets:

- `sunny` -> `Sunny`
- `cloudy` -> `Cloudy`
- `rainy` -> `Rainy`

The background is therefore still driven by the app's primary condition and remains intentionally simple. It does **not** switch to a unique background per fine-grained OpenWeather condition code.

### Bundled Weather Icon Logic

In addition to the coarse background category, the app now keeps the primary OpenWeather condition payload for icon resolution:

- `weather.id`
- `weather.main`
- `weather.description`

The weather condition codes used by the app come directly from OpenWeather's response payload, not from a custom app-defined code table. That means codes such as `800`, `801`, `500`, and `503` are read from `weather.id` in the API response and then mapped to bundled weather icons in code.

The source-of-truth flow is:

- [OpenWeatherService.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Services/Weather/OpenWeatherService.swift) fetches the forecast from OpenWeather
- [OpenWeatherResponse.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Services/Weather/OpenWeatherResponse.swift) decodes `weather.id`
- [OpenWeatherConditionIconMapper.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Services/Weather/OpenWeatherConditionIconMapper.swift) maps those codes to `WeatherIconAsset`
- [WeatherIconAsset.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Domain/Models/WeatherIconAsset.swift) links the mapped case to the actual bundled image asset name

The asset catalog itself does not store weather condition codes. The images live in [Weather Icons](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Assets.xcassets/WeatherAssets/Weather%20Icons), while the weather-code-to-icon association lives entirely in Swift code.

The icon pipeline uses `weather.id` as the primary lookup key because it is the most stable field for condition matching. That ID is mapped to the provided bundled weather icon assets instead of relying only on SF Symbols.

The bundled icon set is treated as the app's primary weather icon library. OpenWeather conditions are mapped into the closest available asset in that set. For example:

- clear sky maps to the bundled sun icon
- few clouds maps to the bundled partly cloudy icon
- heavier cloud coverage maps to bundled cloud-based icons
- drizzle maps to the bundled drizzle icon
- light rain maps to the bundled light-rain icon
- heavy rain maps to the bundled heavy-rain icon
- thunder and thunderstorm conditions map to bundled storm icons
- snow and heavy snow map to bundled snow assets
- sleet and freezing-rain style conditions map to the bundled hailstorm asset
- fog and haze map to a bundled cloud asset
- strong wind, dust, sand, squall, and tornado families map to the bundled heavy-wind asset

Some provided assets are intentionally **not** used for weather-condition matching in the current app because they represent celestial or time-of-day imagery rather than weather conditions themselves. That includes icons such as:

- sunrise
- sunset
- eclipse
- moon variants

Those assets are excluded from the OpenWeather condition mapping because this app is focused on weather-state presentation, not astronomy-state presentation.

### Fallback Behavior

The icon mapping system follows a fallback chain so the UI remains resilient if OpenWeather returns an unmapped or unexpected condition:

1. map from `weather.id`
2. if needed, fall back to `weather.main` / `weather.description` heuristics
3. if still unresolved, fall back to the bundled cloud icon as the default asset
4. if the expected bundled asset cannot be loaded, fall back to an SF Symbol

This means the app now prefers the provided weather icons at runtime, while still keeping a safe fallback path so the UI can render even if an icon is missing or a new OpenWeather condition appears.

### Architectural Intent

The project now separates:

- **weather category for backgrounds**
- **weather icon asset for condition display**

This keeps the background logic stable and easy to reason about, while allowing the forecast rows and current-condition UI to become much more specific without changing the rest of the app's visual architecture.

## Temperature Unit Behavior

The app currently fetches temperatures from OpenWeather in **metric** units and keeps those values in Celsius inside the app's domain models.

Temperature conversion happens only at presentation time:

- if the phone's system temperature preference resolves to Celsius, the app displays `°C`
- if the phone's system temperature preference resolves to Fahrenheit, the app converts the stored Celsius value and displays `°F`

This applies consistently to:

- the current temperature in the forecast header
- each daily temperature shown in the forecast list
- each daily low/high pair shown in formats like `12°C/15°C`

### Daily Low / High Temperature Display

When the UI shows a pair such as `12°C/15°C`, that means:

- `12°C` = the day's low temperature
- `15°C` = the day's high temperature

Those values are derived from OpenWeather's forecast entries for that day and are stored in the app's domain model as:

- `minTemperatureCelsius`
- `maxTemperatureCelsius`

The mapping is assembled in [OpenWeatherForecastMapper.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/Services/Weather/OpenWeatherForecastMapper.swift), which groups forecast entries by day and computes:

- the minimum value from `temp_min` for the daily low
- the maximum value from `temp_max` for the daily high

That daily low/high pair is then formatted for presentation in the forecast list and detail screen.

### Current Limitation

This is intentionally limited.

Right now the app does **not** offer an in-app temperature preference. It only follows the phone's current system preference for temperature units. That is acceptable for a lightweight prototype, but it is not ideal for a production weather app because users may want control that differs from their device-wide regional setting.

Examples:

- a user may want Fahrenheit in the weather app even if their phone is configured for a metric region
- a user may want Celsius in the app while traveling in a locale that defaults to Fahrenheit

### Production Direction

For a production-ready version, the app should add a dedicated settings surface where the user can explicitly choose their preferred temperature unit.

That future settings flow should support:

- `Use System Setting`
- `Celsius`
- `Fahrenheit`

In that model:

- the app would still be able to respect the phone setting by default
- the user would be able to override that default when needed
- the chosen preference would be persisted and used consistently across the entire app

The current implementation does not include that settings page or persistence layer yet. It is a presentation-only improvement that makes the displayed unit match the phone setting without introducing additional app configuration UI.

## Current Weather Metrics

The forecast header now shows a compact current-conditions summary in addition to the icon and temperature. The added values are:

- wind speed in `km/h`
- humidity as a percentage
- precipitation as a percentage

These values are derived from the first forecast entry returned by OpenWeather, which is the same entry the app already uses as the source of truth for the current primary condition and current displayed temperature.

### OpenWeather Fields Used

The app now reads the following additional fields from the OpenWeather 5-day / 3-hour forecast response:

- `main.humidity`
- `wind.speed`
- `pop`

How they are presented in the UI:

- `main.humidity` -> displayed directly as `Humidity`
- `wind.speed` -> converted from meters per second into kilometers per hour and displayed as `Wind`
- `pop` -> converted into a percentage and displayed as `Precip`

### Important Note About Precipitation

The precipitation value currently shown in the app is **not** rainfall volume.

It is OpenWeather's `pop` field, which represents the **probability of precipitation** for that forecast entry. In practical terms:

- `20%` means a 20% chance of precipitation
- it does **not** mean 20 mm of rain

If the app later needs actual precipitation amount, that would require additional handling for fields such as:

- `rain.3h`
- `snow.3h`

Those are separate from precipitation probability and should be treated as different weather metrics in the UI.

### Current Limitation

The current metrics row is intentionally lightweight:

- it uses only the first/current forecast entry
- it does not yet expose gusts, visibility, pressure, or actual rain/snow volume
- precipitation is currently shown as chance-of-precipitation only

This is a good lightweight summary for the current header, but a production-grade weather app would likely expand this into a dedicated details surface or conditions panel.

## Forecast Card Interaction

Users can open a more detailed forecast view by double-tapping any daily weather card in the forecast list.

That interaction pushes a detail screen that shows:

- the selected day's main weather summary
- supporting weather metrics such as feels-like temperature, wind, humidity, and chance of rain
- hourly forecast entries with time-based weather icons
- additional upcoming daily forecast cards based on the available API data

## Configuration

The current testing configuration is defined in [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift).

- `openWeatherAPIKey`

The OpenWeather key is currently stored on the client for testing.

## Build And Run

1. Open [WeatherApp.xcodeproj](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp.xcodeproj).
2. Select the `WeatherApp` scheme.
3. Edit [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift) with your testing values.
4. Run on an iPhone simulator or device with location permissions enabled.

CLI examples:

```bash
xcodebuild build -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Latest Local Verification

The most recent local terminal run on April 2, 2026 used:

```bash
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Result:

- `** TEST SUCCEEDED **`
- 25 unit tests executed
- 0 failures
- 0 unexpected failures
- test execution time: `0.122` seconds
- full test session elapsed time reported by Xcode: `37.088` seconds

Test suites covered in that run:

- `ForecastPresentationFormatterTests` - 4 passing tests
- `ForecastScreenViewModelTests` - 4 passing tests
- `OpenWeatherConditionIconMapperTests` - 11 passing tests
- `OpenWeatherForecastMapperTests` - 1 passing test
- `TemperatureUnitPreferenceTests` - 4 passing tests
- `WeatherThemeTests` - 1 passing test

Artifacts produced by the run:

- Xcode result bundle: `/Users/blessingmabunda/Library/Developer/Xcode/DerivedData/WeatherApp-dtyvrnwyjmpdyrbwuefjuzntmtgl/Logs/Test/Test-WeatherApp-2026.04.02_08-42-15-+0200.xcresult`

## Testing Strategy

- Unit tests cover:
  - OpenWeather response mapping into app-owned models
  - OpenWeather condition-to-icon mapping for bundled weather assets
  - current weather metric mapping for humidity, wind speed, and precipitation probability
  - theme/background mapping
  - forecast view-model state transitions
  - presentation formatting helpers, including Celsius/Fahrenheit display conversion
- Protocol-based test doubles isolate location, network, and weather flows.
- UI verification is handled through SwiftUI previews plus view-model coverage rather than snapshot tooling.

## CI/CD And Coverage

GitHub Actions is configured in [ios.yml](/Users/blessingmabunda/Documents/WeatherApp/.github/workflows/ios.yml). The pipeline is currently a CI workflow rather than a full deployment workflow, so its job is to validate the app on every change to `main` and on pull requests.

The workflow currently runs a single job named `test-and-analyze` on `macos-latest`. That job:

- checks out the repository with `actions/checkout`
- selects the latest stable Xcode with `maxim-lobanov/setup-xcode`
- runs `xcodebuild test` against the `WeatherApp` scheme on the `iPhone 17 Pro` simulator
- enables code coverage during test execution
- writes the test result bundle to `TestResults.xcresult`
- runs `xcodebuild analyze` for static analysis after tests
- exports a human-readable coverage report with `xcrun xccov view --report`
- uploads the generated `coverage.txt` file as a GitHub Actions artifact named `weatherapp-coverage`

In practical terms, CI is enforcing three things on every push and pull request:

- the app target and test target must compile successfully
- the unit tests must pass on the configured simulator destination
- Xcode static analysis must complete without failing the workflow

The artifact handling is intentionally simple. Coverage is not yet posted as a PR comment, uploaded to a third-party dashboard, or used as a merge gate. Instead, the workflow keeps the `coverage.txt` file as a downloadable build artifact for manual inspection from the Actions run page.

There is no CD step yet. The repository does not currently build release archives, sign the app, upload to TestFlight, deploy metadata, or publish artifacts beyond the test coverage report. If release automation is added later, it should be kept separate from the validation job so CI failures and release failures remain easy to distinguish.

If GitHub Actions shows JavaScript runtime warnings such as Node 20 deprecation notices, those warnings are about the GitHub-hosted action runtime used by actions like `actions/checkout`, not about the Swift app itself. They should be handled by updating workflow action versions when newer compatible releases are available.

## Static Analysis

- Native compiler warnings are left enabled in the Xcode project.
- CI runs `xcodebuild analyze` to catch analyzer issues early.
- No third-party static-analysis tool is required for this version of the app.

## Security Consideration

The API key is stored on the client side, which is unsecure, and any bad actors can unbundle the app and gain access to the API key. This is only for testing purposes. If the app was to be mass distributed, the API key would be moved to Firebase Secrets Manager.
