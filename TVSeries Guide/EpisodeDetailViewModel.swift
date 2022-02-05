//
//  EpisodeDetailViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 04/02/22.
//

import UIKit

final class EpisodeDetailViewModel {
    
    private(set) var episode: EpisodeModel
    private let seriesAPI: SeriesAPIProtocol
    
    init(episode: EpisodeModel, seriesAPI: SeriesAPIProtocol = SeriesAPI()) {
        self.episode = episode
        self.seriesAPI = seriesAPI
    }
    
    func fetchImage(completion: @escaping (UIImage?) -> Void) {
        if let image = self.episode.image {
            completion(image)
            return
        }
        guard let url = self.episode.imageURL else {
            completion(nil)
            return
        }
        self.seriesAPI.downloadImage(url: url) { [weak self] result in
            let image = try? result.get()
            self?.episode.image = image
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
