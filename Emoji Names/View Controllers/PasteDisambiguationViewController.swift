//
//  PasteDisambiguationViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/19/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit
import AdaptiveFormSheet

// MARK: PasteDisambiguationViewControllerDelegate

protocol PasteDisambiguationViewControllerDelegate: class {
    
    func pasteDisambiguationViewController(
        _ viewController: PasteDisambiguationViewController,
        didSelectEmoji emoji: String)
    
}

// MARK: PasteDisambiguationViewController

class PasteDisambiguationViewController: AFSModalViewController {
    
    var pastedEmoji: [String]!
    weak var delegate: PasteDisambiguationViewControllerDelegate?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Presentation
    
    static func present(for pastedEmoji: [String], over source: UIViewController) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Paste Disambiguation") as! PasteDisambiguationViewController
        
        if let delegate = source as? PasteDisambiguationViewControllerDelegate {
            viewController.delegate = delegate
        }
        
        viewController.pastedEmoji = pastedEmoji
        source.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: User Interaction
    
    @IBAction func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            delegate?.pasteDisambiguationViewController(self,
                didSelectEmoji: pastedEmoji[selectedIndex])
        }
    }
    
}

// MARK: AFSModalOptionsProvider

extension PasteDisambiguationViewController: AFSModalOptionsProvider {
    
    var dismissWhenUserTapsDimmer: Bool? {
        return false
    }
    
}

// MARK: UICollectionViewDataSource

extension PasteDisambiguationViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int
    {
        return pastedEmoji.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.decorate(for: pastedEmoji[indexPath.item])
        return cell
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension PasteDisambiguationViewController: UICollectionViewDelegateFlowLayout {
    
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
