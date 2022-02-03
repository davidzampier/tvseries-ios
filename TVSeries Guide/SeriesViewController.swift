//
//  SeriesViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

class SeriesViewController: UITableViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundLabel: UILabel!
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Type a series name"
        return controller
    }()
    
    private let viewModel = SeriesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = self.searchController
        self.tableView.backgroundView = UIView()
        self.viewModel.delegate = self
        self.viewModel.fetchSeries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupBackgroundView()
    }
    
    private func setupBackgroundView() {
        guard self.backgroundView.superview == nil else { return }
        self.backgroundView.frame = self.tableView.frame
        self.tableView.backgroundView = self.backgroundView
    }
    
    private func startLoading() {
        self.backgroundLabel.text = "Searching...🕵️‍♂️"
        self.backgroundLabel.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    private func stopLoading() {
        self.backgroundLabel.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    
    // MARK: - TableView Setup
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfItems()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SeriesListViewCell.identifier, for: indexPath) as? SeriesListViewCell else {
            return UITableViewCell()
        }
        let series = self.viewModel.itemFor(indexPath: indexPath)
        cell.nameLabel.text = series.name
        cell.posterImageView.startLoading()
        self.viewModel.fetchPosterFor(series: series) { image in
            if let image = image {
                cell.posterImageView.setImage(image)
                cell.posterImageView.stopLoading()
            } else {
                cell.posterImageView.stopLoadingWithPlaceholder()
            }
        }
        return cell
    }
}


// MARK: - SeriesListViewModelDelegate

extension SeriesViewController: SeriesListViewModelDelegate {
    
    func setLoading(isLoading: Bool) {
        if isLoading {
            self.startLoading()
        } else {
            self.stopLoading()
        }
    }
    
    func didUpdateResults() {
        self.tableView.reloadData()
    }
}


// MARK: - UISearchResultsUpdating

extension SeriesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        self.viewModel.didSearch(text: text)
    }
}
