//
//  SeriesAPI.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

protocol SeriesAPIProtocol {
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void)
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
}


struct SeriesAPI {
    
    private let baseURL = "https://api.tvmaze.com"
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
}

// MARK: - SeriesAPIProtocol

extension SeriesAPI: SeriesAPIProtocol {
    
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void) {
        var url = self.baseURL + "/shows"
        if let page = page {
            url += "?page=\(page)"
        }
        self.networkManager.get(url: url, completion: completion)
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.networkManager.downloadImage(url: url, completion: completion)
    }
}
