//
//  ForwardingNavigationController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class ForwardingNavigationController: UINavigationController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewControllers.forEach { $0.viewDidLayoutSubviews() }
    }
    
}
