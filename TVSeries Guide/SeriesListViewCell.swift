//
//  SeriesListViewCell.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

class SeriesListViewCell: UITableViewCell {
    static let identifier = "SeriesListViewCell"
    
    @IBOutlet weak var posterImageView: NetworkImageView!
    @IBOutlet weak var nameLabel: UILabel!
 
    override func prepareForReuse() {
        self.posterImageView.stopLoading()
        self.posterImageView.setImage(nil)
    }
}
