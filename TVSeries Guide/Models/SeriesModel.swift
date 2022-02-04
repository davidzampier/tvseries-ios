//
//  SeriesModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

final class SeriesModel {
    let id: Int
    let name: String
    let summary: String?
    let imageURL: URL?
    var posterImage: UIImage?
    var seasons: [SeasonModel]?
    
    init(id: Int, name: String, summary: String?, imageURL: URL?, seasons: [SeasonModel]?) {
        self.id = id
        self.name = name
        self.summary = summary
        self.imageURL = imageURL
        self.seasons = seasons
    }
}

final class SeasonModel {
    let id: Int
    let number: Int?
    var episodes: [EpisodeModel]
    
    init(id: Int, number: Int?, episodes: [EpisodeModel]) {
        self.id = id
        self.number = number
        self.episodes = episodes
    }
}

final class EpisodeModel {
    let id: Int
    let number: Int?
    let season: Int
    let name: String
    let summary: String?
    let imageURL: URL?
    
    init(response: SeriesEpisodeResponse) {
        self.id = response.id
        self.number = response.number
        self.season = response.season
        self.name = response.name
        self.summary = response.summary
        self.imageURL = response.image?.medium
    }
}
