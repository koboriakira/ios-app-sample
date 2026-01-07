import Foundation

/// 天気リポジトリ実装
/// APIクライアントを利用してデータを取得し、ドメインモデルに変換
public final class WeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    private let apiClient: WeatherAPIClientProtocol

    public init(apiClient: WeatherAPIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchWeather(cityCode: String) async throws -> Weather {
        let response = try await apiClient.fetchWeather(cityCode: cityCode)
        return response.toDomain()
    }
}
