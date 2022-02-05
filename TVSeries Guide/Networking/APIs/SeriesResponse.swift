//
//  SeriesResponse.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import Foundation

struct SeriesResponse: Decodable {
    let id: Int
    let name: String
    let summary: String?
    let genres: [String]?
    let image: ImageResponse?
}

struct SeriesSearchResponse: Decodable {
    let show: SeriesResponse
}

struct SeriesSeasonResponse: Decodable {
    let id: Int
    let number: Int?
}

struct SeriesEpisodeResponse: Decodable {
    let id: Int
    let number: Int?
    let season: Int
    let name: String
    let summary: String?
    let image: ImageResponse?
}

struct ImageResponse: Decodable {
    let medium: URL
}
