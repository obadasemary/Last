//
//  NetworkService.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T
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
}

enum NetworkError: Error {
    case invalidResponse
    case decodingError
}
