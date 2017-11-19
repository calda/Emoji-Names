//
//  ChooseEmojiViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/19/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit
import AdaptiveFormSheet

// MARK: ChooseEmojiViewControllerDelegate

protocol ChooseEmojiViewControllerDelegate: class {
    
    func chooseEmojiViewController(
        _ viewController: ChooseEmojiViewController,
        didSelectEmoji emoji: String)
    
}

// MARK: ChooseEmojiViewController

class ChooseEmojiViewController: AFSModalViewController {
    
    var emoji: [String]!
    weak var delegate: ChooseEmojiViewControllerDelegate?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Presentation
    
    static func present(for emoji: [String], over source: UIViewController) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Paste Disambiguation") as! ChooseEmojiViewController
        
        if let delegate = source as? ChooseEmojiViewControllerDelegate {
            viewController.delegate = delegate
        }
        
        viewController.emoji = emoji
        source.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: User Interaction
    
    @IBAction func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            delegate?.chooseEmojiViewController(self,
                didSelectEmoji: emoji[selectedIndex])
        }
    }
    
}

// MARK: AFSModalOptionsProvider

extension ChooseEmojiViewController: AFSModalOptionsProvider {
    
    var dismissWhenUserTapsDimmer: Bool? {
        return false
    }
    
}

// MARK: UICollectionViewDataSource

extension ChooseEmojiViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int
    {
        return emoji.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.decorate(for: emoji[indexPath.item])
        return cell
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension ChooseEmojiViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        doneButton.isHidden = false
    }
    
}

// MARK: EmojiCell

class EmojiCell: UICollectionViewCell {
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    
    func decorate(for emoji: String) {
        Setting.preferredEmojiStyle.value.showEmoji(emoji, in: emojiLabel)
    }
    
    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
}
