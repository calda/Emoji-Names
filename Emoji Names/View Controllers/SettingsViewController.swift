//
//  SettingsViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/18/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ viewController: SettingsViewController, didUpdateEmojiStyleTo emojiStyle: EmojiStyle)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        segmentedControl.selectedSegmentIndex = (Setting.preferredEmojiStyle.value == .system) ? 0 : 1
    }
    
    @IBAction func segmentedControlDidChange() {
        let newEmojiStyle: EmojiStyle = (segmentedControl.selectedSegmentIndex == 0) ? .system : .twitter
        Setting.preferredEmojiStyle.update(to: newEmojiStyle)
        delegate?.settingsViewController(self, didUpdateEmojiStyleTo: newEmojiStyle)
    }
    
}
