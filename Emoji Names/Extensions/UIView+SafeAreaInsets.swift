//
//  UIView+SafeAreaInsets.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/18/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

extension UIView {
    
    var safeAreaInsetsIfAvailable: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return  .zero
        }
    }
    
}
