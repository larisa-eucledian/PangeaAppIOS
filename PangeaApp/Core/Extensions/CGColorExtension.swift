//
//  CGColorExtension.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/08/25.
//

import Foundation
import UIKit

extension CGColor {
    var UIColor : UIKit.UIColor {
        return UIKit.UIColor(cgColor: self)
    }
}
