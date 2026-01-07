import SwiftUI

/// アプリケーションのエントリーポイント
@main
public struct WeatherApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            DependencyContainer.shared.makeWeatherView()
        }
    }
}
