//
//  SeriesListViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

protocol SeriesListViewModelDelegate: AnyObject {
    func didUpdateResults()
    func setLoading(isLoading: Bool)
}

final class SeriesListViewModel {
    
    private let seriesAPI: SeriesAPIProtocol
    
    private var series: [SeriesModel] = []
    private var searchedSeries: [SeriesModel]?
    
    var isLoading: Bool = false {
        willSet {
            guard newValue != isLoading else { return }
            self.delegate?.setLoading(isLoading: newValue)
        }
    }
    
    weak var delegate: SeriesListViewModelDelegate?
    
    init(seriesAPI: SeriesAPIProtocol = SeriesAPI()) {
        self.seriesAPI = seriesAPI
    }
    
    
    // MARK: - Table View Setup
    
    func numberOfItems() -> Int {
        self.searchedSeries?.count ?? self.series.count
    }
    
    func itemFor(indexPath: IndexPath) -> SeriesModel {
        self.searchedSeries?[indexPath.row] ?? self.series[indexPath.row]
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
        self.delegate?.didUpdateResults()
    }
    
    
    // MARK: - Fetch Data
    
    func fetchSeries() {
        self.seriesAPI.fetchSeries(page: nil) { [weak self] (result: Result<[SeriesResponse], NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let entities = response.map {
                        SeriesModel(id: $0.id, name: $0.name, summary: $0.summary, imageURL: $0.image.medium)
                    }
                    self?.series.append(contentsOf: entities)
                case .failure:
                    break
                }
                self?.delegate?.didUpdateResults()
            }
        }
    }
    
    func fetchPosterFor(series: SeriesModel, completion: @escaping (UIImage?) -> Void) {
        if let posterImage = series.posterImage {
            completion(posterImage)
            return
        }
        self.seriesAPI.downloadImage(url: series.imageURL) { result in
            DispatchQueue.main.async {
                let image = try? result.get()
                series.posterImage = image
                completion(image)
            }
        }
    }
}
