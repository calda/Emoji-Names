//
//  ShareImageViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/23/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class ShareImageViewController: UIViewController {
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var emojiBackgroundView: UIView!
    @IBOutlet weak var emojiBackgroundExtensionView: UIView!
    
    @IBOutlet weak var colorButtonView: UIView!
    @IBOutlet weak var nameButtonView: UIView!
    @IBOutlet weak var styleButtonView: UIView!
    
    @IBOutlet weak var colorButtonLabel: UILabel!
    @IBOutlet weak var nameButtonLabel: UILabel!
    @IBOutlet weak var styleButtonLabel: UILabel!
    
    var emoji: String!
    var backgroundColor: UIColor?
    var emojiStyle: EmojiStyle!
    var showingName = true
    
    // MARK: Present
    
    static func present(for emoji: String, over source: UIViewController) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Share Image") as! ShareImageViewController
        viewController.emoji = emoji
        viewController.emojiStyle = Setting.preferredEmojiStyle.value
        source.present(viewController, animated: true)
    }
    
    // MARK: Setup
    
    override func viewDidLoad() {
        addTextShadows()
        addButtonShadows()
        updateEmojiView()
        updateButtonLabels()
    }
    
    func addTextShadows() {
        emojiLabel.layer.shadowOpacity = 0.15
        emojiLabel.layer.shadowRadius = 2.0
        emojiLabel.layer.shadowColor = UIColor.black.cgColor
        emojiLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        emojiNameLabel.layer.shadowOpacity = 0.065
        emojiNameLabel.layer.shadowRadius = 2.0
        emojiNameLabel.layer.shadowColor = UIColor.black.cgColor
        emojiNameLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func addButtonShadows() {
        [colorButtonView, nameButtonView, styleButtonView].forEach { buttonView in
            guard let buttonView = buttonView else { return }
            
            buttonView.layer.cornerRadius = 8
            buttonView.layer.shadowPath = UIBezierPath(roundedRect: buttonView.bounds, cornerRadius: 8).cgPath
            buttonView.layer.shadowColor = UIColor.black.cgColor
            buttonView.layer.shadowOffset = CGSize(width: 0, height: 1)
            buttonView.layer.shadowRadius = 2
            buttonView.layer.shadowOpacity = 0.11
        }
    }
    
    // MARK: Presenting
    
    func updateEmojiView() {
        emojiStyle.showEmoji(emoji, in: emojiLabel)
        emojiNameLabel.text = emoji.emojiName
        emojiNameLabel.isHidden = !showingName
        
        let backgroundColor = self.backgroundColor
            ?? emojiStyle.backgroundColor(for: emoji)
        
        emojiBackgroundView.backgroundColor = backgroundColor
        emojiBackgroundExtensionView.backgroundColor = backgroundColor
        
        emojiNameLabel.textColor = backgroundColor.secondaryColorsForBackground.text
    }
    
    func updateButtonLabels() {
        emojiStyle.showEmoji("🎨", in: colorButtonLabel)
        emojiStyle.showEmoji(showingName ? "🏷" : "🚫", in: nameButtonLabel)
        emojiStyle.showEmoji("😄", in: styleButtonLabel)
    }
    
    // MARK: User Interaction
    
    private func setButtonViewSelected(_ buttonView: UIView, selected: Bool) {
        UIView.animate(
            withDuration: 0.225,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
                buttonView.transform = selected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
                buttonView.backgroundColor = selected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        })
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
        
        [colorButtonView, nameButtonView, styleButtonView].forEach { buttonView in
            guard let buttonView = buttonView else { return }
            setButtonViewSelected(buttonView, selected: touchIsInView(buttonView) && !commitAction)
            
            if commitAction && touchIsInView(buttonView) {
                if buttonView == self.colorButtonView { self.colorButtonTapped() }
                if buttonView == self.nameButtonView { self.nameButtonTapped() }
                if buttonView == self.styleButtonView { self.styleButtonTapped() }
            }
        }
    }
    
    private func colorButtonTapped() {
        performSegue(withIdentifier: "color popover", sender: nil)
    }
    
    private func nameButtonTapped() {
        showingName = !showingName
        updateButtonLabels()
        updateEmojiView()
    }
    
    private func styleButtonTapped() {
        emojiStyle = (emojiStyle == .system) ? .twitter : .system
        
        self.updateEmojiView()
        self.updateButtonLabels()
        
        [colorButtonLabel, nameButtonLabel, styleButtonLabel].forEach { view in
            guard let view = view else { return }
            UIView.transition(with: view, duration: 0.35, options: [.transitionFlipFromRight], animations: {})
        }
    }
    
}

// MARK: UIPopoverPresentationControllerDelegate

extension ShareImageViewController: UIPopoverPresentationControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let colorPicker = segue.destination as? ColorPickerViewController {
            colorPicker.popoverPresentationController?.delegate = self
            colorPicker.delegate = self
            colorPicker.defaultColor = emojiStyle.backgroundColor(for: emoji)
            
            if let sourceBounds = colorPicker.popoverPresentationController?.sourceView?.bounds {
                colorPicker.popoverPresentationController?.sourceRect = sourceBounds
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: ColorPickerViewControllerDelegate

extension ShareImageViewController: ColorPickerViewControllerDelegate {
    
    func colorPicker(_ viewController: ColorPickerViewController, didSelectColor color: UIColor) {
        backgroundColor = color
        updateEmojiView()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func colorPickerDidSelectReset(_ viewController: ColorPickerViewController) {
        backgroundColor = nil
        updateEmojiView()
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
