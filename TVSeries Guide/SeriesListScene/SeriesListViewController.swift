//
//  SeriesListViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

class SeriesListViewController: UITableViewController {

    private let passwordSegue = "PasswordSceneSegue"
    private let seriesDetailSegue = "SeriesDetailSceneSegue"
    
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
    
    var viewModel: SeriesListViewModelProtocol = SeriesListViewModel()
    
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
    
    private func showNoResultsLabel() {
        self.stopLoading()
        self.backgroundLabel.text = "No series found 😭"
        self.backgroundLabel.isHidden = false
    }
    
    private func hideNoResultsLabel() {
        self.backgroundLabel.isHidden = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.seriesDetailSegue,
            let destination = segue.destination as? SeriesDetailViewController,
            let selected = self.tableView.indexPathForSelectedRow {
            let series = self.viewModel.itemFor(indexPath: selected)
            destination.viewModel = SeriesDetailViewModel(series: series)
        } else if segue.identifier == self.passwordSegue,
                  let destination = segue.destination as? AuthorizationViewController {
            destination.completion = { [weak self] _ in
                self?.viewModel.fetchSeries()
            }
            if let sheet = segue.destination.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
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
        cell.genresLabel.text = series.genres?.joined(separator: " | ")
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.numberOfItems() - 1 { // Last Item
            self.viewModel.didReachEndOfItems()
        }
    }
}


// MARK: - SeriesListViewModelDelegate

extension SeriesListViewController: SeriesListViewModelDelegate {
    
    func setLoading(isLoading: Bool) {
        if isLoading {
            self.startLoading()
        } else {
            self.stopLoading()
        }
    }
    
    func didUpdateResults() {
        self.tableView.reloadData()
        if !self.viewModel.isLoading {
            if self.viewModel.numberOfItems() > 0 {
                self.hideNoResultsLabel()
            } else {
                self.showNoResultsLabel()
            }
        }
    }
    
    func openAuthorizationScene() {
        self.performSegue(withIdentifier: self.passwordSegue, sender: nil)
    }
}


// MARK: - UISearchResultsUpdating

extension SeriesListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        self.viewModel.didSearch(text: text)
    }
}
