//
//  NetworkManagerTests.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 02/02/22.
//

import XCTest
@testable import TVSeries_Guide

final class NetworkManagerTests: XCTestCase {
    
    lazy var urlSessionMock: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }()
    
    lazy var sut = NetworkManager(urlSession: self.urlSessionMock)

    func testGetSuccess() throws {
        let entity = TestEntity(id: "1234", number: 1234)
        let encoded = try JSONEncoder().encode(entity)
        URLProtocolMock.requestHandler = {
            return .success(encoded)
        }
        let expectation = XCTestExpectation(description: "response")
        
        self.sut.get(url: "https://test.com") { (result: Result<TestEntity, NetworkError>) in
            let expected = try? result.get()
            XCTAssertEqual(expected, entity)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetInvalidURLString() throws {
        let expectedError = NSError(domain: "", code: 0, userInfo: nil)
        URLProtocolMock.requestHandler = {
            return .failure(expectedError)
        }
        
        let expectation = XCTestExpectation(description: "response")
        
        self.sut.get(url: "https://test.com") { (result: Result<TestEntity, NetworkError>) in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .genericError(expectedError))
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetWithRequestError() throws {
        let expectation = XCTestExpectation(description: "response")
        
        self.sut.get(url: "") { (result: Result<TestEntity, NetworkError>) in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .invalidURL)
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetWithDecodingError() throws {
        let expectation = XCTestExpectation(description: "response")
        URLProtocolMock.requestHandler = {
            return .success(Data())
        }
        
        self.sut.get(url: URL(string: "https://test.com")!) { (result: Result<TestEntity, NetworkError>) in
            switch result {
            case .failure(let error):
                guard case .decodingError(_) = error else {
                    XCTFail()
                    return
                }
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDownloadImageWithError() throws {
        URLProtocolMock.requestHandler = {
            return .failure(NSError(domain: "", code: 0, userInfo: nil))
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.sut.downloadImage(url: URL(string: "https://test.com")!) { (result: Result<UIImage, NetworkError>) in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .noData)
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    struct TestEntity: Codable, Equatable {
        let id: String
        let number: Int
    }
}
