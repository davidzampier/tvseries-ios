//
//  SeriesListViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

final class SeriesListViewModel {
    
    private let seriesAPI: SeriesAPIProtocol
    
    private(set) var series: [SeriesModel] = []
    
    var didUpdateViewModel: (() -> Void)?
    
    init(seriesAPI: SeriesAPIProtocol = SeriesAPI()) {
        self.seriesAPI = seriesAPI
    }
    
    func fetchSeries() {
        self.seriesAPI.fetchSeries(page: nil) { (result: Result<[SeriesResponse], NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let entities = response.map {
                        SeriesModel(id: $0.id, name: $0.name, summary: $0.summary, imageURL: $0.image.medium)
                    }
                    self.series.append(contentsOf: entities)
                case .failure:
                    break
                }
                self.didUpdateViewModel?()
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
