//
//  SeriesEpisodeViewCell.swift
//  TVSeries Guide
//
//  Created by David Zampier on 04/02/22.
//

import UIKit

class SeriesEpisodeViewCell: UITableViewCell {
    
    static let identifier = String(describing: SeriesEpisodeViewCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
}
