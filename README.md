# WeatherApp

WeatherApp is a SwiftUI weather client that fetches a 5-day forecast from OpenWeather using the user's current location, then displays a weather-aware background with overlay copy. The codebase is intentionally split into small views and focused services instead of a single monolithic screen.

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
  Services/OverlayText/
  Services/Weather/
  Shared/
WeatherAppTests/
docs/
```

See [docs/Architecture.md](/Users/blessingmabunda/Documents/WeatherApp/docs/Architecture.md) for the detailed architecture breakdown.

## Third-Party Dependencies

No third-party dependencies are currently used.

- OpenWeather is used as an external HTTP API, not as a bundled SDK.
- If cross-cutting tooling is added later, it must stay limited to concerns such as linting, logging, or CI support.

## Configuration

The current testing configuration is defined in [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift).

- `openWeatherAPIKey`
- `overlayTextAPIURL`

The OpenWeather key is currently stored on the client for testing, and the overlay endpoint is left unset so the app uses the development stub overlay provider.

## Build And Run

1. Open [WeatherApp.xcodeproj](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp.xcodeproj).
2. Select the `WeatherApp` scheme.
3. Edit [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift) with your testing values.
4. Run on an iPhone simulator or device with location permissions enabled.

CLI examples:

```bash
xcodebuild build -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Testing Strategy

- Unit tests cover:
  - OpenWeather response mapping into app-owned models
  - theme/background mapping
  - forecast view-model state transitions
  - presentation formatting helpers
- Protocol-based test doubles isolate location, network, weather, and overlay flows.
- UI verification is handled through SwiftUI previews plus view-model coverage rather than snapshot tooling.

## CI/CD And Coverage

- GitHub Actions is configured in [ios.yml](/Users/blessingmabunda/Documents/WeatherApp/.github/workflows/ios.yml).
- The workflow runs:
  - `xcodebuild test`
  - `xcodebuild analyze`
  - `xccov` coverage export
- Coverage is emitted as an artifact so it can be inspected from CI runs.

## Static Analysis

- Native compiler warnings are left enabled in the Xcode project.
- CI runs `xcodebuild analyze` to catch analyzer issues early.
- No third-party static-analysis tool is required for this version of the app.

## Security Consideration

The API key is stored on the client side, which is unsecure, and any bad actors can unbundle the app and gain access to the API key. This is only for testing purposes. If the app was to be mass distributed, the API key would be moved to Firebase Secrets Manager.
