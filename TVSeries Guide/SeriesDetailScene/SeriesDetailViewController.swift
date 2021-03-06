//
//  SeriesDetailViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 03/02/22.
//

import UIKit

class SeriesDetailViewController: UITableViewController {
    
    var viewModel: SeriesDetailViewModelProtocol!
    
    private var headerView: SeriesDetailHeaderView = .initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SeriesEpisodeSeasonHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: SeriesEpisodeSeasonHeaderViewCell.identifier)
        self.setUpHeaderView()
        self.viewModel.delegate = self
        self.viewModel.fetchSeasons()
    }
    
    private func setUpHeaderView() {
        self.headerView.titleLabel.text = self.viewModel.series.name
        self.headerView.imageView.image = self.viewModel.series.posterImage
        self.headerView.summaryLabel.setHTMLText(text: self.viewModel.series.summary ?? "")
        self.headerView.genresLabel.text = self.viewModel.series.genres?.joined(separator: "\n")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? EpisodeDetailViewController,
            let selected = self.tableView.indexPathForSelectedRow,
            let episode = self.viewModel.episodeFor(indexPath: selected) else {
            return
        }
        destination.viewModel = EpisodeDetailViewModel(episode: episode)
        if let sheet = destination.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else {
            return self.headerView
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SeriesEpisodeSeasonHeaderViewCell.identifier) as? SeriesEpisodeSeasonHeaderViewCell
        var title = "Season"
        let season = self.viewModel.seasonFor(section: section)
        if let seasonNumber = season?.number {
            title += " \(seasonNumber)"
        }
        header?.titleLabel.text = title
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? UITableView.automaticDimension : 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SeriesEpisodeViewCell.identifier, for: indexPath) as? SeriesEpisodeViewCell else {
            return UITableViewCell()
        }
        let episode = self.viewModel.episodeFor(indexPath: indexPath)
        let episodeName = episode?.name ?? ""
        if let number = episode?.number {
            cell.titleLabel.text = "\(number). \(episodeName)"
        } else {
            cell.titleLabel.text = episodeName
        }
        cell.summaryLabel.setHTMLText(text: episode?.summary ?? "")
        
        return cell
    }
}


// MARK: - SeriesDetailViewModelDelegate

extension SeriesDetailViewController: SeriesDetailViewModelDelegate {
    
    func didUpdateSeries() {
        self.tableView.reloadData()
    }
}
