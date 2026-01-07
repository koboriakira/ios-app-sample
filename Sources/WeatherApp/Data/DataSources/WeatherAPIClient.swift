import Foundation

/// HTTPクライアントプロトコル
/// URLSessionを抽象化し、テスト時にモックを注入可能にする
public protocol HTTPClientProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// URLSessionのHTTPClientProtocol準拠
extension URLSession: HTTPClientProtocol {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

/// 天気APIクライアントプロトコル
public protocol WeatherAPIClientProtocol: Sendable {
    func fetchWeather(cityCode: String) async throws -> WeatherAPIResponse
}

/// 天気APIクライアント実装
public final class WeatherAPIClient: WeatherAPIClientProtocol, @unchecked Sendable {
    private let httpClient: HTTPClientProtocol
    private let baseURL: String
    private let decoder: JSONDecoder

    public init(
        httpClient: HTTPClientProtocol = URLSession.shared,
        baseURL: String = "https://weather.tsukumijima.net/api/forecast/city"
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
    }

    public func fetchWeather(cityCode: String) async throws -> WeatherAPIResponse {
        guard let url = URL(string: "\(baseURL)/\(cityCode)") else {
            throw WeatherError.invalidCityCode
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await httpClient.data(for: request)
        } catch {
            throw WeatherError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.unknown("Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.serverError(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(WeatherAPIResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError(error.localizedDescription)
        }
    }
}
