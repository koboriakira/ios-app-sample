import XCTest
@testable import WeatherApp

final class FetchWeatherUseCaseTests: XCTestCase {
    private var sut: FetchWeatherUseCase!
    private var mockRepository: MockWeatherRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRepository()
        sut = FetchWeatherUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Success Cases

    func testExecute_success_returnsWeather() async throws {
        // Given
        let expectedWeather = TestFixtures.sampleWeather
        mockRepository.stubbedResult = .success(expectedWeather)

        // When
        let result = try await sut.execute(cityCode: "130010")

        // Then
        XCTAssertEqual(result, expectedWeather)
        XCTAssertEqual(mockRepository.fetchWeatherCallCount, 1)
        XCTAssertEqual(mockRepository.lastRequestedCityCode, "130010")
    }

    func testExecute_callsRepositoryWithCorrectCityCode() async throws {
        // Given
        mockRepository.stubbedResult = .success(TestFixtures.sampleWeather)

        // When
        _ = try await sut.execute(cityCode: "270000")

        // Then
        XCTAssertEqual(mockRepository.lastRequestedCityCode, "270000")
    }

    // MARK: - Error Cases

    func testExecute_emptyCityCode_throwsInvalidCityCode() async {
        // Given
        mockRepository.stubbedResult = .success(TestFixtures.sampleWeather)

        // When/Then
        do {
            _ = try await sut.execute(cityCode: "")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .invalidCityCode)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testExecute_repositoryNetworkError_propagatesError() async {
        // Given
        mockRepository.stubbedResult = .failure(.networkError("Connection failed"))

        // When/Then
        do {
            _ = try await sut.execute(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .networkError("Connection failed"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testExecute_repositoryDecodingError_propagatesError() async {
        // Given
        mockRepository.stubbedResult = .failure(.decodingError("Invalid JSON"))

        // When/Then
        do {
            _ = try await sut.execute(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .decodingError("Invalid JSON"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testExecute_repositoryServerError_propagatesError() async {
        // Given
        mockRepository.stubbedResult = .failure(.serverError(500))

        // When/Then
        do {
            _ = try await sut.execute(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .serverError(500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
