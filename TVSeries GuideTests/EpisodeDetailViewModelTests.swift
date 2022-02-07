//
//  EpisodeDetailViewModelTests.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 05/02/22.
//

import XCTest
@testable import TVSeries_Guide

class EpisodeDetailViewModelTests: XCTestCase {
    
    lazy var seriesAPI = SeriesAPIMock()
    
    func testFetchImage() throws {
        let url = URL(string: "https://image.com/image.png")!
        let episode = self.makeEpisode(imageURL: url, image: nil)
        
        let expectation = XCTestExpectation(description: "response")
        let sut = EpisodeDetailViewModel(episode: episode, seriesAPI: self.seriesAPI)
        sut.fetchImage { image in
            XCTAssertNotNil(image)
            XCTAssertEqual(self.seriesAPI.didCallMethods, [.downloadImage(url: url)])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchImageCached() throws {
        let url = URL(string: "https://image.com/image.png")!
        let episode = self.makeEpisode(imageURL: url, image: UIImage())
        
        let expectation = XCTestExpectation(description: "response")
        let sut = EpisodeDetailViewModel(episode: episode, seriesAPI: self.seriesAPI)
        sut.fetchImage { image in
            XCTAssertNotNil(image)
            XCTAssertEqual(self.seriesAPI.didCallMethods, [])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchImageNoURL() throws {
        let episode = self.makeEpisode(imageURL: nil, image: nil)
        
        let expectation = XCTestExpectation(description: "response")
        let sut = EpisodeDetailViewModel(episode: episode, seriesAPI: self.seriesAPI)
        sut.fetchImage { image in
            XCTAssertNil(image)
            XCTAssertEqual(self.seriesAPI.didCallMethods, [])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchImageFail() throws {
        let url = URL(string: "https://image.com/image.png")!
        let episode = self.makeEpisode(imageURL: url, image: nil)
        self.seriesAPI.downloadImageResponse = .failure(.noData)
        
        let expectation = XCTestExpectation(description: "response")
        let sut = EpisodeDetailViewModel(episode: episode, seriesAPI: self.seriesAPI)
        sut.fetchImage { image in
            XCTAssertNil(image)
            XCTAssertEqual(self.seriesAPI.didCallMethods, [.downloadImage(url: url)])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
            
    private func makeEpisode(imageURL: URL?, image: UIImage?) -> EpisodeModel {
        EpisodeModel(id: 1,
                     number: 1,
                     season: 1,
                     name: "Test Episode",
                     summary: nil,
                     imageURL: imageURL,
                     image: image)
    }
}
