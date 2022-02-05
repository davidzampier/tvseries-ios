//
//  SeriesAPITests.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 04/02/22.
//

import XCTest
@testable import TVSeries_Guide

class SeriesAPITests: XCTestCase {
    
    private let baseURL = Constants.seriesAPIBaseURL.absoluteString
    
    private lazy var networkManager = NetworkManagerMock()
    private lazy var sut = SeriesAPI(networkManager: self.networkManager)

    func testFetchSeriesNoPage() throws {
        let expectedURL = self.baseURL + "/shows"
        
        self.sut.fetchSeries(page: nil) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.get(url: expectedURL)])
    }
    
    func testFetchSeriesWithPage() throws {
        let page = 2
        let expectedURL = self.baseURL + "/shows?page=\(page)"
        
        self.sut.fetchSeries(page: page) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.get(url: expectedURL)])
    }
    
    func testSearchSeries() throws {
        let text = "The Mentalist"
        let expectedURL = self.baseURL + "/search/shows?q=The%20Mentalist"
        
        self.sut.searchSeries(text: text) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.get(url: expectedURL)])
    }
    
    func testFetchSeasons() throws {
        let seriesID = 1
        let expectedURL = self.baseURL + "/shows/\(seriesID)/seasons"
        
        self.sut.fetchSeasons(seriesID: seriesID) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.get(url: expectedURL)])
    }
    
    func testFetchEpisodes() throws {
        let seasonID = 1
        let expectedURL = self.baseURL + "/seasons/\(seasonID)/episodes"
        
        self.sut.fetchEpisodes(seasonID: seasonID) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.get(url: expectedURL)])
    }
    
    func testDownloadImage() throws {
        let url = URL(string: self.baseURL)!
        
        self.sut.downloadImage(url: url) { _ in }
        
        XCTAssertEqual(self.networkManager.didCallMethods, [.downloadImage(url: url.absoluteString)])
    }
}
