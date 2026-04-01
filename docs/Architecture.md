# WeatherApp Architecture

## Overview

WeatherApp uses **MVVM** with feature-oriented folders. The goal is to keep each responsibility small and replaceable:

- Views render only display state.
- The feature view model coordinates loading and state transitions.
- Services isolate location, networking, weather retrieval, and overlay-text retrieval.
- Domain models define the app's own data shape so SwiftUI does not depend on raw API DTOs.

## Folder Responsibilities

### `App/`

- `AppConfiguration` loads runtime configuration from the generated Info.plist.
- `AppContainer` wires concrete services into the root feature.

### `Domain/Models/`

- `LocationCoordinate`
- `ForecastDay`
- `WeatherConditionCategory`
- `WeatherOverlay`
- `WeatherSnapshot`
- `ForecastScreenState`

These types are app-owned and stable across service changes.

### `Features/Forecast/ViewModels/`

- `ForecastScreenViewModel` owns the async user flow:
  - request location permission
  - fetch forecast
  - fetch overlay text
  - publish `idle`, `requestingPermission`, `loading`, `loaded`, `permissionDenied`, or `error`

### `Features/Forecast/Views/`

The forecast screen is intentionally decomposed into separate views:

- `ForecastScreen`
- `WeatherBackgroundView`
- `ForecastHeaderView`
- `ForecastListView`
- `ForecastRowView`
- `ForecastLoadingView`
- `ForecastErrorView`

This keeps layout, styling, and state-driven branching out of a single oversized `body`.

### `Services/`

- `Location/`: Core Location wrapper behind `LocationProviding`
- `Networking/`: HTTP abstraction and URLSession implementation
- `Weather/`: OpenWeather integration, DTOs, mapping, and protocol
- `OverlayText/`: remote overlay-text provider plus a development stub

### `Shared/`

- display formatting helpers
- weather-to-background theme mapping

## Dependency Rules

- SwiftUI views may depend on the feature view model and shared presentation helpers.
- View models may depend only on protocols and domain models, not concrete networking or Core Location types.
- Services may depend on networking helpers and DTOs, then map into domain models before returning.
- DTOs stay internal to the weather/overlay service layer.
- Shared helpers must remain stateless and reusable.

## Data Flow

1. `WeatherAppApp` creates the dependency container.
2. `ForecastScreen` starts loading on first appearance.
3. `ForecastScreenViewModel` requests the current location through `LocationProviding`.
4. `WeatherProviding` fetches OpenWeather's 5-day forecast using `URLSession`.
5. `OpenWeatherForecastMapper` converts the API payload into `WeatherSnapshot` and `ForecastDay` values.
6. `OverlayTextProviding` requests overlay copy from a remote endpoint. If no endpoint is configured, the app uses a development stub.
7. The view model publishes the final `ForecastScreenState.loaded` state.
8. SwiftUI views render the weather background, header, overlay text, and forecast list from display-ready domain data.

## Why This Avoids A Monolith

The original template placed everything in a single `ContentView`. That approach does not scale once location handling, networking, API mapping, retry logic, and multiple view states appear. This implementation avoids that by:

- isolating async flow in one view model
- keeping each UI section in its own small view
- separating transport DTOs from domain models
- keeping configuration and dependency wiring out of the feature screen

## Extension Points

This structure leaves clear room for future work without rewriting the screen:

- add hourly forecast or detail screens under `Features/`
- add caching or offline storage behind `WeatherProviding`
- replace the development overlay stub with a production overlay service
- add new presentation themes without touching service code
