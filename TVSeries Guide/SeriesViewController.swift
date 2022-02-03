//
//  SeriesViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

class SeriesViewController: UITableViewController {

    private let viewModel = SeriesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.fetchSeries()
        self.viewModel.didUpdateViewModel = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.series.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SeriesListViewCell.identifier, for: indexPath) as? SeriesListViewCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = self.viewModel.series[indexPath.row].name
        return cell
    }
}
