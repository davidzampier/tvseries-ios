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
    
    init(id: Int, name: String, summary: String?, imageURL: URL?) {
        self.id = id
        self.name = name
        self.summary = summary
        self.imageURL = imageURL
    }
}