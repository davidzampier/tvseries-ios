//
//  NetworkImageView.swift
//  TVSeries Guide
//
//  Created by David Zampier on 02/02/22.
//

import UIKit

final class NetworkImageView: UIView {
    
    var hasImage: Bool {
        self.imageView.image != nil
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
    
    func startLoading() {
        guard self.activityIndicator.superview == nil else { return }
        self.activityIndicator.center = self.center
        self.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    func stopLoadingWithPlaceholder() {
        self.stopLoading()
        self.imageView.image = UIImage(systemName: "film")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(self.imageView)
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
