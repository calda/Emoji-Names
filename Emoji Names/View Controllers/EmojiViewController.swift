//
//  EmojiViewController.swift
//  Emoji Names
//
//  Created by DFA Film 9: K-9 on 4/14/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import Crashlytics
import StoreKit

class EmojiViewController: UIViewController {
    
    @IBOutlet weak var hiddenField: UITextField!
    @IBOutlet weak var showKeyboardButton: UIButton!
    @IBOutlet weak var openKeyboardView: UIView!
    @IBOutlet weak var openKeyboardPosition: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var previousEmojiImage: UIImageView!
    @IBOutlet weak var previousBackground: UIImageView!
    var previousEmojiColor = UIColor.clear
    var keyboardHeight: CGFloat? = 0
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpStatusBarView()
        addTextShadows()
        
        updateContentHeight(animate: false)
        changeToEmoji("😀", animate: false)
        emojiNameLabel.text = "Open the Emoji Keyboard and press an emoji"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name:. UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        self.openKeyboardView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.openKeyboardView.layer.cornerRadius = 20.0
        self.openKeyboardView.layer.masksToBounds = true
        
        showKeyboardButton.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateContentHeight(animate: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showKeyboard()
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.showKeyboardButton.alpha = 1.0
        }, completion: nil)
    }
    
    func setUpStatusBarView() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08)
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        self.topBar = statusBarView
        
        view.addSubview(statusBarView)
        if #available(iOS 11.0, *) {
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            statusBarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            statusBarView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            statusBarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            statusBarView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            statusBarView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
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
    
    //MARK: - Handle rotation and resizing
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.layoutIfNeeded()
        updateContentHeight(animate: true)
        changeToEmoji(emojiLabel.text ?? "😀", animate: false)
    }
    
    //MARK: - Showing and Hiding the Keyboard
    
    @IBAction func showKeyboard() { //called from app delegate or UIButton
        hiddenField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.showKeyboardButton.alpha = 1.0
            self.updateContentHeight()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !hiddenField.isFirstResponder {
            showKeyboard()
        }
    }
    
    var keyboardHidden = false
    
    @objc func keyboardChanged(_ notification: Notification) {
        guard let info = notification.userInfo,
            let value = info[UIKeyboardFrameEndUserInfoKey],
            let rawFrame = (value as AnyObject).cgRectValue else
        {
            return
        }
        
        let keyboardFrame = view.convert(rawFrame, from: nil)
        if keyboardFrame.minY >= view.frame.maxY {
            self.keyboardHeight = nil
        } else {
            self.keyboardHeight = keyboardFrame.height
        }
        
        updateContentHeight()
        
        if keyboardHidden {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.0,
                options: [],
                animations: { self.view.layoutIfNeeded() })
        } else {
            self.view.layoutIfNeeded()
        }
        
        keyboardHidden = false
        
    }
    
    private var _preferredStatusBarStyle = UIStatusBarStyle.lightContent
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return _preferredStatusBarStyle
    }

    var isAnimatingPopup = false
    
    func showOpenKeyboardPopup() {
        
        if isAnimatingPopup { return }
        isAnimatingPopup = true
        self.openKeyboardView.alpha = 1.0
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.openKeyboardView.transform = CGAffineTransform.identity
        })
        
        UIView.animate(
            withDuration: 0.4,
            delay: 2.5,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.openKeyboardView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            }, completion: { _ in
                self.isAnimatingPopup = false
                self.openKeyboardView.alpha = 0.0
        })
        
    }
    
    func updateContentHeight(animate: Bool = true) {
        contentBottomConstraint.constant = keyboardHeight ?? 0
        
        let animations = { self.view.layoutIfNeeded() }
        
        if !animate {
            animations()
            return
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: animations,
            completion: nil)
    }
    
    
    //MARK: - emoji input and processing
    
    @IBAction func hiddenInputReceived(_ sender: UITextField, forEvent event: UIEvent) {
        defer {
            sender.text = nil
        }
        
        guard let emoji = sender.text, emoji.isEmoji else {
            sender.text = ""
            showOpenKeyboardPopup()
            return
        }
        
        //track emoji count for rate alert
        if emoji != self.emojiLabel.text {
            
            let emojiCount = UserDefaults.standard.integer(forKey: "emojiCount")
            UserDefaults.standard.set(emojiCount + 1, forKey: "emojiCount")
            
            if emojiCount == 25 {
                if #available(iOS 10.3, *) {
                    showKeyboardButton.alpha = 0.0
                    UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
                        self.showKeyboardButton.alpha = 1.0
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
                        self.hiddenField.resignFirstResponder()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
                        SKStoreReviewController.requestReview()
                    }
                }
            }
        }
        
        changeToEmoji(emoji)
    }
    
    func changeToEmoji(_ emoji: String, animate: Bool = true) {
        copyCurrentEmojiToImageView()
        
        Setting.preferredEmojiStyle.value.showEmoji(emoji, in: emojiLabel)
        emojiNameLabel.text = emoji.emojiName
        
        Answers.logCustomEvent(
            withName: "Emoji Viewed",
            customAttributes: [
                "Emoji": emoji,
                "Emoji Name": emoji.emojiName])
        
        let primaryColor = Setting.preferredEmojiStyle.value.backgroundColor(for: emoji)
        emojiView.backgroundColor = primaryColor
        
        let (textColor, statusBarColor) = primaryColor.secondaryColorsForBackground
        emojiNameLabel.textColor = textColor
        self.view.backgroundColor = primaryColor
        
        if animate {
            animateTransition(usesDifferentColors: !previousEmojiColor.approxEquals(primaryColor))
        }
        
        _preferredStatusBarStyle = (statusBarColor.luma > 0.27) ? .default : .lightContent
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        previousEmojiColor = primaryColor
    }
    
    //MARK: - Transition between emoji
    
    func animateTransition(usesDifferentColors showCircularMask: Bool) {
        
        if showCircularMask {
            let frame = emojiView.frame
            let diameter = max(frame.size.height, frame.size.width) * 2.0
            
            let xOffset = -(diameter - frame.width) / 2.0
            let yOffset = -(diameter - frame.height) / 2.0
            let internalFrame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: CGSize(width: diameter, height: diameter))
            
            let circle = CALayer()
            circle.frame = internalFrame
            circle.cornerRadius = diameter / 2.0
            circle.backgroundColor = UIColor.black.cgColor
            
            emojiView.layer.masksToBounds = true
            emojiView.layer.mask = circle
            
            //animate mask
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            circle.add(animation, forKey: "scale")
        }
        
        //animate opacity real fast
        emojiView.alpha = 0.0
        UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.emojiView.alpha = 1.0
        }, completion: nil)
        
        //animate scale
        emojiNameLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        emojiNameLabel.alpha = 0.0
        emojiLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        emojiLabel.alpha = 0.0
        previousEmojiImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        previousEmojiImage.alpha = 1.0
        
        if !showCircularMask { emojiView.backgroundColor = UIColor.clear }
        
        UIView.animate(withDuration: 0.7, delay: 0.05, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.emojiNameLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.emojiNameLabel.alpha = 1.0
            self.emojiLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.emojiLabel.alpha = 1.0
            self.previousEmojiImage.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.previousEmojiImage.alpha = 0.0
        }, completion: { _ in
            self.previousBackground.image = nil
            self.emojiView.layer.mask = nil
        })
    }
    
    func copyCurrentEmojiToImageView() {
        UIGraphicsBeginImageContextWithOptions(emojiView.bounds.size, false, 0.0)
        
        //get picture of just emoji
        emojiView.backgroundColor = UIColor.clear
        topBar.isHidden = true
        previousEmojiImage.isHidden = true
        
        emojiView.layer.render(in: UIGraphicsGetCurrentContext()!)
        previousEmojiImage.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsGetCurrentContext()?.clear(emojiView.bounds)
        emojiView.backgroundColor = self.previousEmojiColor
        previousEmojiImage.isHidden = false
        
        //get picture of just background
        topBar.isHidden = false
        emojiLabel.isHidden = true
        emojiNameLabel.isHidden = true
        
        emojiView.layer.render(in: UIGraphicsGetCurrentContext()!)
        previousBackground.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        emojiLabel.isHidden = false
        emojiNameLabel.isHidden = false
    }
    
}
