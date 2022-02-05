//
//  SeriesEpisodeSeasonHeaderViewCell.swift
//  TVSeries Guide
//
//  Created by David Zampier on 04/02/22.
//

import UIKit

final class SeriesEpisodeSeasonHeaderViewCell: UITableViewHeaderFooterView {
    
    static let identifier = String(describing: SeriesEpisodeSeasonHeaderViewCell.self)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2, compatibleWith: nil)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.backgroundColor = .opaqueSeparator
        NSLayoutConstraint.activate([
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
}
