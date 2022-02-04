//
//  Helpers.swift
//  TVSeries Guide
//
//  Created by David Zampier on 03/02/22.
//

import UIKit

extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
