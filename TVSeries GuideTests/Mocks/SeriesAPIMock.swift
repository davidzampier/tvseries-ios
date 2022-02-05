//
//  SeriesAPIMock.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 04/02/22.
//

import UIKit
@testable import TVSeries_Guide

final class SeriesAPIMock {
    
    private(set) var didCallMethods: [Method] = []
    
    var fetchSeriesResponse: Result<[SeriesResponse], NetworkError> = .success([])
    var searchSeriesResponse: Result<[SeriesSearchResponse], NetworkError> = .success([])
    var fetchSeasonsResponse: Result<[SeriesSeasonResponse], NetworkError> = .success([])
    var fetchEpisodesResponse: Result<[SeriesEpisodeResponse], NetworkError> = .success([])
    var downloadImageResponse: Result<UIImage, NetworkError> = .success(UIImage())
    
    enum Method: Equatable {
        case fetchSeries(page: Int?)
        case searchSeries(text: String)
        case fetchSeasons(seriesID: Int)
        case fetchEpisodes(seasonID: Int)
        case downloadImage(url: URL)
    }
}


// MARK: - SeriesAPIProtocol

extension SeriesAPIMock: SeriesAPIProtocol {
    
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void) {
        self.didCallMethods.append(.fetchSeries(page: page))
        completion(self.fetchSeriesResponse)
    }
    
    func searchSeries(text: String, completion: @escaping (Result<[SeriesSearchResponse], NetworkError>) -> Void) {
        self.didCallMethods.append(.searchSeries(text: text))
        completion(self.searchSeriesResponse)
    }
    
    func fetchSeasons(seriesID: Int, completion: @escaping (Result<[SeriesSeasonResponse], NetworkError>) -> Void) {
        self.didCallMethods.append(.fetchSeasons(seriesID: seriesID))
        completion(self.fetchSeasonsResponse)
    }
    
    func fetchEpisodes(seasonID: Int, completion: @escaping (Result<[SeriesEpisodeResponse], NetworkError>) -> Void) {
        self.didCallMethods.append(.fetchEpisodes(seasonID: seasonID))
        completion(self.fetchEpisodesResponse)
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.didCallMethods.append(.downloadImage(url: url))
        completion(self.downloadImageResponse)
    }
}
