import Foundation

/// 天気データ取得のリポジトリプロトコル
/// Data層の実装とDomain層を分離し、テスト時にモックを注入可能にする
public protocol WeatherRepositoryProtocol: Sendable {
    /// 指定された都市コードの天気予報を取得
    /// - Parameter cityCode: 都市コード (例: "130010" = 東京)
    /// - Returns: 天気予報データ
    /// - Throws: WeatherError
    func fetchWeather(cityCode: String) async throws -> Weather
}

/// 天気取得時に発生しうるエラー
public enum WeatherError: Error, Equatable, LocalizedError {
    case networkError(String)
    case decodingError(String)
    case invalidCityCode
    case serverError(Int)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .decodingError(let message):
            return "データ解析エラー: \(message)"
        case .invalidCityCode:
            return "無効な都市コードです"
        case .serverError(let code):
            return "サーバーエラー (コード: \(code))"
        case .unknown(let message):
            return "不明なエラー: \(message)"
        }
    }
}
