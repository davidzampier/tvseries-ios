//
//  SeriesDetailViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 03/02/22.
//

import UIKit

class SeriesDetailViewController: UITableViewController {
    
    var viewModel: SeriesDetailViewModel!
    
    private var headerView: SeriesDetailHeaderView = .initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpHeaderView()
    }
    
    private func setUpHeaderView() {
        self.headerView.titleLabel.text = self.viewModel.series.name
        self.headerView.imageView.image = self.viewModel.series.posterImage
        self.headerView.summaryLabel.text = self.viewModel.series.summary
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
}


