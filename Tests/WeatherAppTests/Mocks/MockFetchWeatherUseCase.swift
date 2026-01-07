import Foundation
@testable import WeatherApp

/// テスト用のモックユースケース
final class MockFetchWeatherUseCase: FetchWeatherUseCaseProtocol, @unchecked Sendable {
    var stubbedResult: Result<Weather, WeatherError>?
    var executeCallCount = 0
    var lastRequestedCityCode: String?
    var delay: UInt64 = 0

    func execute(cityCode: String) async throws -> Weather {
        executeCallCount += 1
        lastRequestedCityCode = cityCode

        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }

        guard let result = stubbedResult else {
            fatalError("stubbedResult must be set before calling execute")
        }

        switch result {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
