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
    let summary: String
    let image: Image
    
    struct Image: Decodable {
        let medium: URL
    }
}
