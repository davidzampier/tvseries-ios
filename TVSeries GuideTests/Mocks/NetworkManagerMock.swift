//
//  NetworkManagerMock.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 04/02/22.
//

import UIKit
@testable import TVSeries_Guide

final class NetworkManagerMock {
    
    private(set) var didCallMethods: [Method] = []
    
    enum Method: Equatable {
        case downloadImage(url: String)
        case get(url: String)
    }
}


// MARK: - NetworkManagerProtocol

extension NetworkManagerMock: NetworkManagerProtocol {
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.didCallMethods.append(.downloadImage(url: url.absoluteString))
    }
    
    func get<T>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        self.didCallMethods.append(.get(url: url))
    }
    
    func get<T>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        self.didCallMethods.append(.get(url: url.absoluteString))
    }
}
