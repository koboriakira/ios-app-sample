import Foundation
import WeatherCore

/// テスト用のモックリポジトリ
public final class MockWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    public var stubbedResult: Result<Weather, WeatherError>?
    public var fetchWeatherCallCount = 0
    public var lastRequestedCityCode: String?

    public init() {}

    public func fetchWeather(cityCode: String) async throws -> Weather {
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
