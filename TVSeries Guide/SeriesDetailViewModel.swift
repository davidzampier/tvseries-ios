//
//  SeriesDetailViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 03/02/22.
//

import Foundation

protocol SeriesDetailViewModelProtocol: AnyObject {
    func didUpdateSeries()
}

final class SeriesDetailViewModel {
    
    private(set) var series: SeriesModel
    private let seriesAPI: SeriesAPIProtocol
    
    weak var delegate: SeriesDetailViewModelProtocol?
    
    init(series: SeriesModel, seriesAPI: SeriesAPIProtocol = SeriesAPI()) {
        self.series = series
        self.seriesAPI = seriesAPI
    }
    
    func numberOfSections() -> Int {
        (self.series.seasons?.count ?? 0) + 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return self.series.seasons?[section - 1].episodes.count ?? 0
    }
    
    func seasonFor(section: Int) -> SeasonModel? {
        self.series.seasons?[section - 1]
    }
    
    func episodeFor(indexPath: IndexPath) -> EpisodeModel? {
        self.series.seasons?[indexPath.section - 1].episodes[indexPath.row]
    }
    
    func fetchSeasons() {
        guard series.seasons == nil else { return }
        self.seriesAPI.fetchSeasons(seriesID: series.id) { [weak self] (result: Result<[SeriesSeasonResponse], NetworkError>) in
            guard let response = try? result.get() else { return }
            let seasons = response.map({ SeasonModel(id: $0.id, number: $0.number, episodes: []) })
            self?.fetchEpisodes(seasons: seasons)
        }
    }
    
    func fetchEpisodes(seasons: [SeasonModel]) {
        let dispatchGroup = DispatchGroup()
        for season in seasons {
            dispatchGroup.enter()
            self.seriesAPI.fetchEpisodes(seasonID: season.id) { (result: Result<[SeriesEpisodeResponse], NetworkError>) in
                guard let response = try? result.get() else { return }
                season.episodes = response.map({ EpisodeModel(response: $0) })
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.series.seasons = seasons
            self.delegate?.didUpdateSeries()
        }
    }
}
