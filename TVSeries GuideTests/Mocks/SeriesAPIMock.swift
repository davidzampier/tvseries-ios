//
//  SeriesAPIMock.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 04/02/22.
//

import UIKit
@testable import TVSeries_Guide

final class SeriesAPIMock: SeriesAPIProtocol {
    
    func fetchSeries(page: Int?, completion: @escaping (Result<[SeriesResponse], NetworkError>) -> Void) {
        
    }
    
    func searchSeries(text: String, completion: @escaping (Result<[SeriesSearchResponse], NetworkError>) -> Void) {
        
    }
    
    func fetchSeasons(seriesID: Int, completion: @escaping (Result<[SeriesSeasonResponse], NetworkError>) -> Void) {
        
    }
    
    func fetchEpisodes(seasonID: Int, completion: @escaping (Result<[SeriesEpisodeResponse], NetworkError>) -> Void) {
        
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        
    }
}
