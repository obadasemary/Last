//
//  NetworkServiceTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 06.11.2025.
//

import Testing
import Foundation
import Combine
@testable import Last

@Suite(.serialized)
struct NetworkServiceTests {

    // MARK: - Async/Await Tests

    @MainActor
    @Test("NetworkService async execute - Success with valid JSON")
    func asyncExecute_WithValidJSON_ReturnsDecodedData() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = """
        {
            "info": {
                "count": 1,
                "pages": 1
            },
            "results": []
        }
        """.data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When
        let result: FeedEntity = try await networkService.execute(request)

        // Then
        #expect(result.info.count == 1)
        #expect(result.info.pages == 1)
        #expect(result.results.isEmpty)
    }

    @MainActor
    @Test("NetworkService async execute - Invalid response (404)")
    func asyncExecute_WithInvalidStatusCode_ThrowsInvalidResponseError() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await networkService.execute(request)
            Issue.record("Expected to throw NetworkError.invalidResponse")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
        } catch {
            Issue.record("Expected NetworkError.invalidResponse but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService async execute - Invalid JSON")
    func asyncExecute_WithInvalidJSON_ThrowsDecodingError() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = "invalid json".data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await networkService.execute(request)
            Issue.record("Expected to throw NetworkError.decodingError")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
        } catch {
            Issue.record("Expected NetworkError.decodingError but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService async execute - Network error")
    func asyncExecute_WithNetworkError_ThrowsError() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = NSError(domain: "TestError", code: -1009, userInfo: nil)

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await networkService.execute(request)
            Issue.record("Expected to throw network error")
        } catch {
            #expect(error is NSError)
        }
    }

    // MARK: - Completion Handler Tests
    @MainActor
    @Test("NetworkService completion handler - Success with valid JSON")
    func completionExecute_WithValidJSON_ReturnsSuccess() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = """
        {
            "info": {
                "count": 2,
                "pages": 1
            },
            "results": []
        }
        """.data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When
        let result: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            networkService.execute(request) { (result: Result<FeedEntity, Error>) in
                continuation.resume(with: result)
            }
        }

        // Then
        #expect(result.info.count == 2)
        #expect(result.info.pages == 1)
        #expect(result.results.isEmpty)
    }

    @MainActor
    @Test("NetworkService completion handler - Invalid response")
    func completionExecute_WithInvalidStatusCode_ReturnsFailure() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                networkService.execute(request) { (result: Result<FeedEntity, Error>) in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw NetworkError.invalidResponse")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
        } catch {
            Issue.record("Expected NetworkError.invalidResponse but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService completion handler - Decoding error")
    func completionExecute_WithInvalidJSON_ReturnsFailure() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = "not valid json".data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                networkService.execute(request) { (result: Result<FeedEntity, Error>) in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw NetworkError.decodingError")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
        } catch {
            Issue.record("Expected NetworkError.decodingError but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService completion handler - Network error")
    func completionExecute_WithNetworkError_ReturnsFailure() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = NSError(domain: "TestError", code: -1009, userInfo: nil)

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                networkService.execute(request) { (result: Result<FeedEntity, Error>) in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw network error")
        } catch {
            #expect(error is NSError)
        }
    }

    // MARK: - Combine Tests

    @MainActor
    @Test("NetworkService Combine - Success with valid JSON")
    func combineExecute_WithValidJSON_ReturnsDecodedData() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = """
        {
            "info": {
                "count": 3,
                "pages": 1
            },
            "results": []
        }
        """.data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When
        let publisher: AnyPublisher<FeedEntity, Error> = networkService.execute(request)
        let result: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { value in
                    continuation.resume(returning: value)
                }
            )
        }

        // Then
        #expect(result.info.count == 3)
        #expect(result.info.pages == 1)
        #expect(result.results.isEmpty)
    }

    @MainActor
    @Test("NetworkService Combine - Invalid response")
    func combineExecute_WithInvalidStatusCode_PublishesError() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = networkService.execute(request)
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher.sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
            Issue.record("Expected to throw NetworkError.invalidResponse")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
        } catch {
            Issue.record("Expected NetworkError.invalidResponse but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService Combine - Decoding error")
    func combineExecute_WithInvalidJSON_PublishesError() async throws {
        // Given
        MockURLProtocol.reset()
        let mockData = "invalid json data".data(using: .utf8)!

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockError = nil

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = networkService.execute(request)
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher.sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
            Issue.record("Expected to throw NetworkError.decodingError")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
        } catch {
            Issue.record("Expected NetworkError.decodingError but got \(error)")
        }
    }

    @MainActor
    @Test("NetworkService Combine - Network error")
    func combineExecute_WithNetworkError_PublishesError() async throws {
        // Given
        MockURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = NSError(domain: "TestError", code: -1009, userInfo: nil)

        let session = URLSession(configuration: configuration)
        let networkService = NetworkService(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = networkService.execute(request)
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher.sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
            Issue.record("Expected to throw network error")
        } catch {
            #expect(error is NSError)
        }
    }
}

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol {
    private static var _lock = NSLock()
    private static var _mockData: Data?
    private static var _mockResponse: URLResponse?
    private static var _mockError: Error?

    static var mockData: Data? {
        get {
            _lock.lock()
            defer { _lock.unlock() }
            return _mockData
        }
        set {
            _lock.lock()
            defer { _lock.unlock() }
            _mockData = newValue
        }
    }

    static var mockResponse: URLResponse? {
        get {
            _lock.lock()
            defer { _lock.unlock() }
            return _mockResponse
        }
        set {
            _lock.lock()
            defer { _lock.unlock() }
            _mockResponse = newValue
        }
    }

    static var mockError: Error? {
        get {
            _lock.lock()
            defer { _lock.unlock() }
            return _mockError
        }
        set {
            _lock.lock()
            defer { _lock.unlock() }
            _mockError = newValue
        }
    }

    static func reset() {
        _lock.lock()
        defer { _lock.unlock() }
        _mockData = nil
        _mockResponse = nil
        _mockError = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let error = MockURLProtocol.mockError
        let response = MockURLProtocol.mockResponse
        let data = MockURLProtocol.mockData

        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        // No-op
    }
}

// MARK: - NetworkError Equatable

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError):
            return true
        default:
            return false
        }
    }
}
