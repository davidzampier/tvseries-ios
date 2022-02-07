//
//  Helpers.swift
//  TVSeries Guide
//
//  Created by David Zampier on 03/02/22.
//

import UIKit
import Foundation

struct Constants {
    static let seriesAPIBaseURL = URL(string: "https://api.tvmaze.com")!
}

extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}


extension UILabel {
    
    func setHTMLText(text: String) {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html,
                                                                           .characterEncoding: String.Encoding.utf8.rawValue]
        guard let data = text.data(using: .utf8),
              let attributedString = try? NSAttributedString(data: data,
                                                             options: options,
                                                             documentAttributes: nil) else {
                  return
              }
        self.text = attributedString.string
    }
}

protocol DispatchGroupProtocol {
    func enter()
    func leave()
    func notify(queue: DispatchQueue, execute work: @escaping () -> Void)
}

extension DispatchGroup: DispatchGroupProtocol {
    func notify(queue: DispatchQueue, execute work: @escaping () -> Void) {
        self.notify(qos: .unspecified,
                    flags: [],
                    queue: queue,
                    execute: work)
    }
}
