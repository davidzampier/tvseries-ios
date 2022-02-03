//
//  NetworkManager.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import Foundation

protocol NetworkManagerProtocol {
    func get<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void)
}

struct NetworkManager {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
}


// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {
    
    func get<T>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        urlSession.dataTask(with: url) { data, urlResponse, error in
            if let error = error {
                completion(.failure(.genericError(error)))
                return
            }
            do {
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}


// MARK: - NetworkError

enum NetworkError: Error {
    case genericError(Error), decodingError(Error), invalidURL, noData
}

