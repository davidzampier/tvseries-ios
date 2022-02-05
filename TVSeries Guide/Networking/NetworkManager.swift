//
//  NetworkManager.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import Foundation
import UIKit

protocol NetworkManagerProtocol {
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
    func get<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void)
    func get<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void)
}

struct NetworkManager {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
}


// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.urlSession.dataTask(with: url) { data, urlResponse, error in
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(.noData))
            }
        }.resume()
    }
    
    func get<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        self.get(url: url, completion: completion)
    }
    
    func get<T>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        self.urlSession.dataTask(with: url) { data, urlResponse, error in
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

enum NetworkError: Error, Equatable {
    case genericError(Error), decodingError(Error), invalidURL, noData
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.genericError(let lError), .genericError(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        case (.decodingError(let lError), .decodingError(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        default:
            return false
        }
        
    }
}

