//
//  NetworkService.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T
    func execute<T: Decodable>(_ request: URLRequest, onCompleted: @escaping (Result<T, Error>) -> Void)
}

final class NetworkService {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkService: NetworkServiceProtocol {
    
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
}

enum NetworkError: Error {
    case invalidResponse
    case decodingError
}
