//
//  NetworkService.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ request: URLRequest, onCompleted: @escaping (Result<T, Error>) -> Void)
    func execute<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class NetworkService {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkService: NetworkServiceProtocol {
    
    func execute<T: Decodable>(
        _ request: URLRequest,
        onCompleted: @escaping (Result<T, Error>) -> Void
    ) {

        let task = session.dataTask(with: request) { data, response, error in

            if let error = error {
                onCompleted(.failure(error))
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                onCompleted(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                onCompleted(.success(decodedResponse))
            } catch {
                onCompleted(.failure(NetworkError.decodingError))
            }
        }

        task.resume()
    }

    func execute<T: Decodable>(
        _ request: URLRequest
    ) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse
                , (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case decodingError
}
