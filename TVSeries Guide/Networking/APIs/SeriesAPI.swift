//
//  SeriesAPI.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

protocol SeriesAPIProtocol {
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void)
    func searchSeries(text: String, completion: @escaping (Result<[SeriesSearchResponse], NetworkError>) -> Void)
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
}


struct SeriesAPI {
    
    private let baseURL = URL(string: "https://api.tvmaze.com")!
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
}

// MARK: - SeriesAPIProtocol

extension SeriesAPI: SeriesAPIProtocol {
    
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void) {
        var url = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false)
        url?.path = "/shows"
        if let page = page {
            url?.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        guard let url = url?.url else {
            completion(.failure(.invalidURL))
            return
        }
        self.networkManager.get(url: url, completion: completion)
    }
    
    func searchSeries(text: String, completion: @escaping (Result<[SeriesSearchResponse], NetworkError>) -> Void) {
        var url = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false)
        url?.path = "/search/shows"
        url?.queryItems = [URLQueryItem(name: "q", value: "\(text)")]
        guard let url = url?.url else {
            completion(.failure(.invalidURL))
            return
        }
        self.networkManager.get(url: url, completion: completion)
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.networkManager.downloadImage(url: url, completion: completion)
    }
}
