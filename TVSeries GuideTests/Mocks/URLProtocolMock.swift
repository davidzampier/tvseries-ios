//
//  URLProtocolMock.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 04/02/22.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    
    static var requestHandler: (() -> Result<Data, Error>) = { .success(Data()) }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        let expectedResponse = URLProtocolMock.requestHandler()
        switch expectedResponse {
        case .success(let data):
            client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
}
