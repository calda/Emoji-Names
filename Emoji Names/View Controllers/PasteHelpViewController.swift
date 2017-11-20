//
//  PasteHelpViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/19/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit
import AdaptiveFormSheet

class PasteHelpViewController: AFSModalViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyText: UILabel!
    
    // MARK: Presentation
    
    static func present(over source: UIViewController) {
        let pasteHelp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Paste Help")
        source.present(pasteHelp, animated: true, completion: nil)
    }
    
    // MARK: Setup
    
    override func viewDidLoad() {
        imageView.image = Setting.preferredEmojiStyle.value == .system
            ? UIImage(named: "Copy Message - System")
            : UIImage(named: "Copy Message - Twitter")
        
        // tighten the text style a bit
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = -3.5
        
        let attributedString = NSMutableAttributedString(
            string: bodyText.text?.replacingOccurrences(of: "\\n", with: "\n") ?? "",
            attributes: [.paragraphStyle: paragraphStyle])
        
        bodyText.attributedText = attributedString
        
        // subscribe to notifications
        NotificationCenter.default.addObserver(self,
            selector: #selector(appDidEnterBackgroundNotificationReceived),
            name: .appDidEnterBackground,
            object: nil)
    
    }
    
    @objc func appDidEnterBackgroundNotificationReceived() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: User Interaction
    
    @IBAction func userTappedDone() {
        dismiss(animated: true, completion: nil)
    }
    
}
