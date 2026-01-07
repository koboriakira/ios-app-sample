import Foundation

/// 天気予報取得のユースケースプロトコル
public protocol FetchWeatherUseCaseProtocol: Sendable {
    func execute(cityCode: String) async throws -> Weather
}

/// 天気予報取得のユースケース実装
/// ビジネスロジックをカプセル化し、Presentation層から呼び出される
public final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol, @unchecked Sendable {
    private let repository: WeatherRepositoryProtocol

    public init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    /// 天気予報を取得
    /// - Parameter cityCode: 都市コード
    /// - Returns: 天気予報データ
    public func execute(cityCode: String) async throws -> Weather {
        guard !cityCode.isEmpty else {
            throw WeatherError.invalidCityCode
        }

        return try await repository.fetchWeather(cityCode: cityCode)
    }
}
