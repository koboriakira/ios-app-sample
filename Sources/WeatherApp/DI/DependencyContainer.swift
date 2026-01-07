import Foundation

/// 依存性注入コンテナ
/// アプリケーション全体の依存関係を管理し、テスト時にモックへの差し替えを容易にする
@MainActor
public final class DependencyContainer {
    // MARK: - Shared Instance

    public static let shared = DependencyContainer()

    // MARK: - Configuration

    private var httpClient: HTTPClientProtocol
    private var apiBaseURL: String

    // MARK: - Initialization

    public init(
        httpClient: HTTPClientProtocol = URLSession.shared,
        apiBaseURL: String = "https://weather.tsukumijima.net/api/forecast/city"
    ) {
        self.httpClient = httpClient
        self.apiBaseURL = apiBaseURL
    }

    // MARK: - Factory Methods

    /// APIクライアントを生成
    public func makeWeatherAPIClient() -> WeatherAPIClientProtocol {
        WeatherAPIClient(httpClient: httpClient, baseURL: apiBaseURL)
    }

    /// リポジトリを生成
    public func makeWeatherRepository() -> WeatherRepositoryProtocol {
        WeatherRepository(apiClient: makeWeatherAPIClient())
    }

    /// ユースケースを生成
    public func makeFetchWeatherUseCase() -> FetchWeatherUseCaseProtocol {
        FetchWeatherUseCase(repository: makeWeatherRepository())
    }

    /// ViewModelを生成
    public func makeWeatherViewModel() -> WeatherViewModel {
        WeatherViewModel(fetchWeatherUseCase: makeFetchWeatherUseCase())
    }

    /// 完全に構成されたWeatherViewを生成
    public func makeWeatherView() -> WeatherView {
        WeatherView(viewModel: makeWeatherViewModel())
    }

    // MARK: - Test Configuration

    /// テスト用に依存関係を差し替え
    public func configure(
        httpClient: HTTPClientProtocol? = nil,
        apiBaseURL: String? = nil
    ) {
        if let httpClient = httpClient {
            self.httpClient = httpClient
        }
        if let apiBaseURL = apiBaseURL {
            self.apiBaseURL = apiBaseURL
        }
    }

    /// デフォルト設定にリセット
    public func reset() {
        self.httpClient = URLSession.shared
        self.apiBaseURL = "https://weather.tsukumijima.net/api/forecast/city"
    }
}
