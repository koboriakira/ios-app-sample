import Foundation
@testable import WeatherApp

/// テスト用のモックリポジトリ
final class MockWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    var stubbedResult: Result<Weather, WeatherError>?
    var fetchWeatherCallCount = 0
    var lastRequestedCityCode: String?

    func fetchWeather(cityCode: String) async throws -> Weather {
        fetchWeatherCallCount += 1
        lastRequestedCityCode = cityCode

        guard let result = stubbedResult else {
            fatalError("stubbedResult must be set before calling fetchWeather")
        }

        switch result {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
