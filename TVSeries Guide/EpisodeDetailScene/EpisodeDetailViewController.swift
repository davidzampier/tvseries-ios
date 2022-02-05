//
//  EpisodeDetailViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 04/02/22.
//

import UIKit

class EpisodeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var viewModel: EpisodeDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.startLoading()
        self.imageView.imageViewContentMode = .scaleAspectFit
        self.viewModel.fetchImage { [weak self] image in
            guard let image = image else {
                self?.imageView.isHidden = true
                return
            }
            self?.imageView.stopLoading()
            self?.imageView.setImage(image)
        }
        self.setUpDetails()
    }
    
    private func setUpDetails() {
        self.nameLabel.text = self.viewModel.episode.name
        self.summaryLabel.setHTMLText(text: self.viewModel.episode.summary ?? "")
        self.setUpSeasonLabel()
    }
    
    private func setUpSeasonLabel() {
        var text = "Season \(self.viewModel.episode.season)"
        if let episodeNumber = self.viewModel.episode.number {
            text += "  |  Episode \(episodeNumber)"
        }
        self.seasonLabel.text = text
    }
}
