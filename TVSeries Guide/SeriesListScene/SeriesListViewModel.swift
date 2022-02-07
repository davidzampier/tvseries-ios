//
//  SeriesListViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

protocol SeriesListViewModelProtocol: AnyObject {
    var delegate: SeriesListViewModelDelegate? { get set }
    var isLoading: Bool { get }
    var isSearching: Bool { get }
    func numberOfItems() -> Int
    func itemFor(indexPath: IndexPath) -> SeriesModel
    func didReachEndOfItems()
    func didSearch(text: String?)
    func fetchSeries()
    func fetchPosterFor(series: SeriesModel, completion: @escaping (UIImage?) -> Void)
    func searchSeries(text: String)
}

protocol SeriesListViewModelDelegate: AnyObject {
    func didUpdateResults()
    func setLoading(isLoading: Bool)
    func openAuthorizationScene()
}

final class SeriesListViewModel {
    
    private let seriesAPI: SeriesAPIProtocol
    private let authorizationManager: AuthorizationManagerProtocol
    
    private var series: [SeriesModel] = []
    private var searchedSeries: [SeriesModel]?
    
    private var didFetchAllItems: Bool = false
    
    weak var delegate: SeriesListViewModelDelegate?
    
    var isLoading: Bool = false {
        willSet {
            guard newValue != self.isLoading else { return }
            self.delegate?.setLoading(isLoading: newValue)
        }
    }
    
    init(seriesAPI: SeriesAPIProtocol = SeriesAPI(),
         authorizationManager: AuthorizationManagerProtocol = AuthorizationManager.shared) {
        self.seriesAPI = seriesAPI
        self.authorizationManager = authorizationManager
    }
    
    
    // MARK: - Private Methods
    
    private func isAuthorized() -> Bool {
        self.authorizationManager.authorizationType == nil || self.authorizationManager.status == .authorized
    }
}


// MARK: - SeriesListViewModelProtocol

extension SeriesListViewModel: SeriesListViewModelProtocol {
    
    var isSearching: Bool {
        self.searchedSeries != nil
    }
    
    
    // MARK: - Table View Setup
    
    func numberOfItems() -> Int {
        self.searchedSeries?.count ?? self.series.count
    }
    
    func itemFor(indexPath: IndexPath) -> SeriesModel {
        self.searchedSeries?[indexPath.row] ?? self.series[indexPath.row]
    }
    
    func didReachEndOfItems() {
        if !self.isSearching, !self.didFetchAllItems {
            self.fetchSeries()
        }
    }
    
    
    // MARK: - Search
    
    func didSearch(text: String?) {
        let text = text ?? ""
        guard !text.isEmpty else {
            self.isLoading = false
            self.searchedSeries = nil
            self.delegate?.didUpdateResults()
            return
        }
        self.isLoading = true
        if self.searchedSeries == nil {
            self.searchedSeries = []
        }
        guard text.count > 3 else { return }
        self.searchSeries(text: text)
    }
    
    
    // MARK: - Fetch Data
    
    func fetchSeries() {
        guard self.isAuthorized() else {
            self.delegate?.openAuthorizationScene()
            return
        }
        var page: Int = 0
        if let lastIndex = self.series.last?.id {
            page = (lastIndex/250) + 1
        }
        self.seriesAPI.fetchSeries(page: page) { [weak self] (result: Result<[SeriesResponse], NetworkError>) in
            DispatchQueue.main.async {
                guard let response = try? result.get() else { return }
                let entities = response.map {
                    SeriesModel(id: $0.id, name: $0.name, summary: $0.summary, genres: $0.genres, imageURL: $0.image?.medium, seasons: nil)
                }
                self?.didFetchAllItems = entities.isEmpty
                self?.series.append(contentsOf: entities)
                self?.delegate?.didUpdateResults()
            }
        }
    }
    
    func fetchPosterFor(series: SeriesModel, completion: @escaping (UIImage?) -> Void) {
        if let posterImage = series.posterImage {
            completion(posterImage)
            return
        }
        guard let url = series.imageURL else {
            completion(nil)
            return
        }
        self.seriesAPI.downloadImage(url: url) { result in
            DispatchQueue.main.async {
                let image = try? result.get()
                series.posterImage = image
                completion(image)
            }
        }
    }
    
    func searchSeries(text: String) {
        self.seriesAPI.searchSeries(text: text) { [weak self] (result: Result<[SeriesSearchResponse], NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let entities = response.map {
                        SeriesModel(id: $0.show.id, name: $0.show.name, summary: $0.show.summary, genres: $0.show.genres, imageURL: $0.show.image?.medium, seasons: nil)
                    }
                    self?.searchedSeries = entities
                case .failure:
                    self?.searchedSeries = []
                }
                self?.isLoading = false
                self?.delegate?.didUpdateResults()
            }
        }
    }
    
}
