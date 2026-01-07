import Foundation
@testable import WeatherApp

/// テスト用のモックHTTPクライアント
final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var stubbedData: Data?
    var stubbedResponse: URLResponse?
    var stubbedError: Error?
    var requestCallCount = 0
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestCallCount += 1
        lastRequest = request

        if let error = stubbedError {
            throw error
        }

        guard let data = stubbedData, let response = stubbedResponse else {
            fatalError("stubbedData and stubbedResponse must be set")
        }

        return (data, response)
    }

    /// 成功レスポンスを設定
    func stubSuccess(data: Data, statusCode: Int = 200) {
        stubbedData = data
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        stubbedError = nil
    }

    /// エラーレスポンスを設定
    func stubError(_ error: Error) {
        stubbedData = nil
        stubbedResponse = nil
        stubbedError = error
    }

    /// HTTPエラーを設定
    func stubHTTPError(statusCode: Int) {
        stubbedData = Data()
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        stubbedError = nil
    }
}
