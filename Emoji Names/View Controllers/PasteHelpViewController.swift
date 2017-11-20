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
        imageView.image = CopyState.inactive.image(using: Setting.preferredEmojiStyle.value)
        
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
    
    enum CopyState {
        case inactive
        case active
        case copied
        
        func image(using emojiStyle: EmojiStyle) -> UIImage? {
            let styleName = (emojiStyle == .system) ? "System" : "Twitter"
            switch self {
            case .inactive: return UIImage(named: "Copy Message - \(styleName) - Inactive")
            case .active:   return UIImage(named: "Copy Message - \(styleName) - Active")
            case .copied:   return UIImage(named: "Copy Message - \(styleName) - Copied")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, commitAction: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, commitAction: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, commitAction: true)
    }
    
    private func handleTouches(_ touches: Set<UITouch>, commitAction: Bool) {
        guard let touch = touches.first else {
            return
        }
        
        let touchInImage = imageView.bounds.contains(touch.location(in: imageView))
        
        if !commitAction {
            let state = touchInImage ? CopyState.active : .inactive
            imageView.image = state.image(using: Setting.preferredEmojiStyle.value)
        } else {
            let state = touchInImage ? CopyState.copied : .inactive
            
            UIView.transition(
                with: imageView,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.imageView.image = state.image(using: Setting.preferredEmojiStyle.value) },
                completion: nil)
            
            // copy if commiting touch in image
            if touchInImage {
                UIPasteboard.general.string = "Can't wait!! 🤩🙌🐶"
            }
        }
    }
    
}
