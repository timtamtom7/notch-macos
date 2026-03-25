import Foundation
import CoreLocation

// MARK: - Weather Models

struct WeatherData: Codable {
    let temperature: Int
    let condition: String
    let code: Int
}

// MARK: - Weather Response Models

struct WTTRResponse: Codable {
    let current_condition: [WTTRCurrentCondition]
}

struct WTTRCurrentCondition: Codable {
    let temp_C: String
    let weatherCode: String
    let weatherDesc: [WTTRWeatherDesc]
}

struct WTTRWeatherDesc: Codable {
    let value: String
}

// MARK: - Weather Service

class WeatherService: NSObject, CLLocationManagerDelegate {
    static let shared = WeatherService()

    private let settings = SettingsStore.shared
    private var locationManager: CLLocationManager?
    private var locationCompletion: ((String?) -> Void)?

    override init() {
        super.init()
    }

    func fetchWeather(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        // Check cache first
        if settings.isWeatherCacheValid(),
           let cachedData = settings.cachedWeatherData,
           let weather = try? JSONDecoder().decode(WeatherData.self, from: cachedData) {
            completion(.success(weather))
            return
        }

        // Determine location
        let location = settings.weatherLocation == "Auto" ? "" : settings.weatherLocation

        if location.isEmpty {
            // Try to get current location
            getCurrentLocation { [weak self] city in
                self?.fetchWeatherForLocation(city ?? "London", completion: completion)
            }
        } else {
            fetchWeatherForLocation(location, completion: completion)
        }
    }

    private func fetchWeatherForLocation(_ location: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "London"
        let urlString = "https://wttr.in/\(encodedLocation)?format=j1"

        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }

            do {
                let wtrResponse = try JSONDecoder().decode(WTTRResponse.self, from: data)
                if let current = wtrResponse.current_condition.first {
                    let temp = Int(current.temp_C) ?? 0
                    let code = Int(current.weatherCode) ?? 0
                    let condition = current.weatherDesc.first?.value ?? "Unknown"

                    let weather = WeatherData(temperature: temp, condition: condition, code: code)

                    // Cache the result
                    self?.settings.cachedWeatherData = try? JSONEncoder().encode(weather)
                    self?.settings.cachedWeatherTimestamp = Date()

                    completion(.success(weather))
                } else {
                    completion(.failure(WeatherError.parsingFailed))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func getCurrentLocation(completion: @escaping (String?) -> Void) {
        locationCompletion = completion

        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        }

        let status = locationManager?.authorizationStatus ?? .notDetermined

        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .authorized, .authorizedAlways:
            locationManager?.requestLocation()
        default:
            completion(nil)
        }
    }

    // MARK: - Weather Code to SF Symbol Mapping

    static func weatherIcon(for code: Int) -> String {
        switch code {
        case 113: return "sun.max.fill"
        case 116: return "cloud.sun.fill"
        case 119, 122: return "cloud.fill"
        case 143, 248, 260: return "cloud.fog.fill"
        case 176, 263, 265, 281, 284, 353, 355, 356, 359, 362, 365, 377, 389: return "cloud.rain.fill"
        case 179, 182, 185, 227, 230, 320, 321, 326, 329, 332, 335, 338: return "cloud.snow.fill"
        case 200, 201, 202, 210, 211, 212, 221, 230, 231, 232: return "cloud.bolt.fill"
        case 232: return "tornado"
        case 311, 314, 317, 350: return "cloud.drizzle.fill"
        default: return "cloud.fill"
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationCompletion?(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let city = placemarks?.first?.locality ?? placemarks?.first?.administrativeArea
            self?.locationCompletion?(city)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(nil)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorized, .authorizedAlways:
            manager.requestLocation()
        default:
            locationCompletion?(nil)
        }
    }
}

// MARK: - Errors

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case noData
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid weather URL"
        case .noData: return "No data received"
        case .parsingFailed: return "Failed to parse weather data"
        }
    }
}
