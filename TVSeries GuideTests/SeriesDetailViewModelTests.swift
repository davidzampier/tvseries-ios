//
//  SeriesDetailViewModelTests.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 05/02/22.
//

import XCTest
@testable import TVSeries_Guide

class SeriesDetailViewModelTests: XCTestCase {
    
    private lazy var delegateMock = SeriesDetailViewModelDelegateMock()
    private lazy var seriesAPI = SeriesAPIMock()
    private lazy var dispatchGroup = DispatchGroupMock()
    
    func testNoSeasons() throws {
        let series = self.makeSeries(id: 1, seasons: nil)
        
        let sut = SeriesDetailViewModel(series: series,
                                        seriesAPI: self.seriesAPI,
                                        dispatchGroup: self.dispatchGroup)
        
        XCTAssertEqual(sut.numberOfSections(), 1)
        XCTAssertEqual(sut.numberOfRowsInSection(0), 0)
        XCTAssertEqual(self.seriesAPI.didCallMethods, [])
    }
    
    func testFetchSeasons() throws {
        let seasonsResponse: [SeriesSeasonResponse] = [
            .init(id: 1, number: 1),
            .init(id: 2, number: 2)
        ]
        let episodesResponse: [SeriesEpisodeResponse] = [
            self.makeEpisodeResponse(id: 1, number: 1, season: 1),
            self.makeEpisodeResponse(id: 2, number: 2, season: 1),
            self.makeEpisodeResponse(id: 3, number: 3, season: 1)
        ]
        self.seriesAPI.fetchSeasonsResponse = .success(seasonsResponse)
        self.seriesAPI.fetchEpisodesResponse = .success(episodesResponse)
        let series = self.makeSeries(id: 1, seasons: nil)
        
        let sut = SeriesDetailViewModel(series: series,
                                        seriesAPI: self.seriesAPI,
                                        dispatchGroup: self.dispatchGroup)
        sut.delegate = self.delegateMock
        sut.fetchSeasons()
        
        XCTAssertEqual(sut.numberOfSections(), 3)
        XCTAssertEqual(sut.numberOfRowsInSection(0), 0)
        XCTAssertEqual(sut.numberOfRowsInSection(1), 3)
        XCTAssertEqual(sut.numberOfRowsInSection(2), 3)
        XCTAssertEqual(sut.series.seasons?.count, 2)
        XCTAssertEqual(sut.series.seasons?[0].episodes.count, 3)
        XCTAssertEqual(sut.series.seasons?[1].episodes.count, 3)
        XCTAssertEqual(sut.seasonFor(section: 1)?.id, 1)
        XCTAssertEqual(sut.seasonFor(section: 2)?.id, 2)
        XCTAssertEqual(sut.episodeFor(indexPath: IndexPath(row: 2, section: 1))?.id, 3)
        let expectedMethods: [SeriesAPIMock.Method] = [
            .fetchSeasons(seriesID: series.id),
            .fetchEpisodes(seasonID: 1),
            .fetchEpisodes(seasonID: 2)
        ]
        XCTAssertEqual(self.seriesAPI.didCallMethods, expectedMethods)
        XCTAssertEqual(self.delegateMock.didCallMethods, [.didUpdateSeries])
        XCTAssertEqual(self.dispatchGroup.didCallMethods, [.enter, .leave, .enter, .leave, .notify])
    }
    
    func testFetchSeasonsCached() throws {
        let seasons: [SeasonModel] = [
            .init(id: 1, number: 1, episodes: [
                .init(id: 1, number: 1, season: 1, name: "", summary: nil, imageURL: nil, image: nil),
                .init(id: 2, number: 2, season: 1, name: "", summary: nil, imageURL: nil, image: nil),
            ]),
            .init(id: 2, number: 2, episodes: [
                .init(id: 3, number: 1, season: 2, name: "", summary: nil, imageURL: nil, image: nil),
                .init(id: 4, number: 2, season: 2, name: "", summary: nil, imageURL: nil, image: nil),
            ])
        ]
        let series = self.makeSeries(id: 1, seasons: seasons)
        
        let sut = SeriesDetailViewModel(series: series,
                                        seriesAPI: self.seriesAPI,
                                        dispatchGroup: self.dispatchGroup)
        sut.delegate = self.delegateMock
        sut.fetchSeasons()
        
        XCTAssertEqual(sut.numberOfSections(), 3)
        XCTAssertEqual(sut.numberOfRowsInSection(0), 0)
        XCTAssertEqual(sut.numberOfRowsInSection(1), 2)
        XCTAssertEqual(sut.numberOfRowsInSection(2), 2)
        XCTAssertEqual(sut.series.seasons?.count, 2)
        XCTAssertEqual(sut.series.seasons?[0].episodes.count, 2)
        XCTAssertEqual(sut.series.seasons?[1].episodes.count, 2)
        XCTAssertEqual(sut.seasonFor(section: 1)?.id, 1)
        XCTAssertEqual(sut.seasonFor(section: 2)?.id, 2)
        XCTAssertEqual(sut.episodeFor(indexPath: IndexPath(row: 1, section: 1))?.id, 2)
        XCTAssertEqual(self.seriesAPI.didCallMethods, [])
        XCTAssertEqual(self.delegateMock.didCallMethods, [])
        XCTAssertEqual(self.dispatchGroup.didCallMethods, [])
    }
    
    private func makeSeries(id: Int = 1, seasons: [SeasonModel]? = nil) -> SeriesModel {
        SeriesModel(id: id,
                    name: "Series Name",
                    summary: nil,
                    genres: nil,
                    imageURL: nil,
                    seasons: seasons)
    }
    
    private func makeEpisodeResponse(id: Int, number: Int, season: Int) -> SeriesEpisodeResponse {
        SeriesEpisodeResponse(id: id,
                              number: number,
                              season: season,
                              name: "Episode Name",
                              summary: nil,
                              image: nil)
    }
}


// MARK: - SeriesDetailViewModelDelegateMock

private class SeriesDetailViewModelDelegateMock: SeriesDetailViewModelProtocol {
    
    var didCallMethods: [Method] = []
    
    enum Method {
        case didUpdateSeries
    }
    
    func didUpdateSeries() {
        self.didCallMethods.append(.didUpdateSeries)
    }
}
