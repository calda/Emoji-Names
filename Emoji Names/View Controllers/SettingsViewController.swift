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
    func emojiToShowInSetingsViewController(_ viewController: SettingsViewController) -> String
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var systemEmojiLabel: UILabel!
    @IBOutlet weak var twitterEmojiLabel: UILabel!
    
    @IBOutlet weak var systemSelectionView: UIView!
    @IBOutlet weak var twitterSelectionView: UIView!
    
    weak var delegate: SettingsViewControllerDelegate?
    
    // MARK: Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        updateSelection(to: Setting.preferredEmojiStyle.value)
        
        let emoji = delegate?.emojiToShowInSetingsViewController(self) ?? "😉"
        EmojiStyle.system.showEmoji(emoji, in: self.systemEmojiLabel)
        EmojiStyle.twitter.showEmoji(emoji, in: self.twitterEmojiLabel)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(emojiViewControllerWillChangeEmojiNotificationReceived(_:)),
            name: .emojiViewControllerWillChangeEmoji,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardHeightChangedNotificaitonReceived(_:)),
            name: .keyboardHeightChanged,
            object: nil)
    }
    
    @objc private func emojiViewControllerWillChangeEmojiNotificationReceived(_ notification: Notification) {
        if let newEmoji = notification.userInfo?["new emoji"] as? String {
            UIView.transition(
                with: systemEmojiLabel,
                duration: 0.3,
                options: .transitionFlipFromLeft,
                animations: { EmojiStyle.system.showEmoji(newEmoji, in: self.systemEmojiLabel) })
            
            UIView.transition(
                with: twitterEmojiLabel,
                duration: 0.3,
                options: .transitionFlipFromLeft,
                animations: { EmojiStyle.twitter.showEmoji(newEmoji, in: self.twitterEmojiLabel) })
        }
    }
    
    @objc private func keyboardHeightChangedNotificaitonReceived(_ notification: Notification) {
        dismiss(animated: false)
        self.presentingViewController?.performSegue(
            withIdentifier: "emojiStylePopover",
            sender: self.popoverPresentationController?.sourceView)
    }
    
    // MARK: User Interaction
    
    func updateSelection(to emojiStyle: EmojiStyle?) {
        let selected = UIColor(white: 1.0, alpha: 0.85)
        systemSelectionView.backgroundColor = (emojiStyle == .system) ? selected : .clear
        twitterSelectionView.backgroundColor = (emojiStyle == .twitter) ? selected : .clear
    }
    
    func commitSelection(of emojiStyle: EmojiStyle) {
        guard Setting.preferredEmojiStyle.value != emojiStyle else {
            return
        }
        
        Setting.preferredEmojiStyle.update(to: emojiStyle)
        delegate?.settingsViewController(self, didUpdateEmojiStyleTo: emojiStyle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        handleTouches(touches, commitAction: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        handleTouches(touches, commitAction: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        handleTouches(touches, commitAction: true)
    }
    
    private func handleTouches(_ touches: Set<UITouch>, commitAction: Bool) {
        func touchIsInView(_ view: UIView) -> Bool {
            guard let locationInView = touches.first?.location(in: view) else {
                return false
            }
            
            return view.bounds.contains(locationInView)
        }
        
        let systemSelected = touchIsInView(systemSelectionView)
        let twitterSelected = touchIsInView(twitterSelectionView)
        
        if !systemSelected && !twitterSelected && commitAction {
            updateSelection(to: Setting.preferredEmojiStyle.value)
            return
        }
        
        if systemSelected {
            updateSelection(to: .system)
        } else if twitterSelected {
            updateSelection(to: .twitter)
        } else {
            updateSelection(to: nil)
        }
        
        if commitAction {
            commitSelection(of: systemSelected ? .system : .twitter)
        }
    }
    
}
