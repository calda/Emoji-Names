//
//  ViewController.swift
//  Emoji Playlist
//
//  Created by DFA Film 9: K-9 on 4/14/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var hiddenField: UITextField!
    @IBOutlet weak var showKeyboardButton: UIButton!
    @IBOutlet weak var openKeyboardView: UIView!
    @IBOutlet weak var openKeyboardPosition: NSLayoutConstraint!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var previousEmojiImage: UIImageView!
    @IBOutlet weak var previousBackground: UIImageView!
    var previousEmojiColor = UIColor.clear
    var emojiCount = 0
    var keyboardHeight : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateContentHeight(animate: false)
        changeToEmoji("😀", animate: false)
        emojiNameLabel.text = "Open the Emoji Keyboard and press an emoji"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name:. UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        self.openKeyboardView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.openKeyboardView.layer.cornerRadius = 20.0
        self.openKeyboardView.layer.masksToBounds = true
        
        showKeyboardButton.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.showKeyboardButton.alpha = 1.0
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateContentHeight(animate: false)
    }
    
    //MARK: - Showing and Hiding the Keyboard
    
    @IBAction func showKeyboard() { //called from app delegate or UIButton
        hiddenField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.showKeyboardButton.alpha = 1.0
            self.updateContentHeight()
        })
    }
    
    var keyboardHidden = false
    
    @objc func keyboardChanged(_ notification: Notification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        self.keyboardHeight = keyboardFrame.height
        
        let duration = "\(info[UIKeyboardAnimationDurationUserInfoKey]!)"
        updateContentHeight(animate: duration != "0")
        
        if keyboardHidden {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { self.view.layoutIfNeeded() }, completion: nil)
        } else {
            self.view.layoutIfNeeded()
        }
        
        keyboardHidden = false
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    var isAnimatingPopup = false
    
    func showOpenKeyboardPopup() {
        
        if isAnimatingPopup { return }
        isAnimatingPopup = true
        self.openKeyboardView.alpha = 1.0
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.openKeyboardView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 2.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.openKeyboardView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }, completion: { _ in
            self.isAnimatingPopup = false
            self.openKeyboardView.alpha = 0.0
        })
        
    }
    
    func updateContentHeight(animate: Bool = true) {
        let availableHeight = self.view.frame.height - keyboardHeight
        contentHeight.constant = availableHeight
        
        let animations = { self.view.layoutIfNeeded() }
        
        if !animate {
            animations()
            return
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: animations, completion: nil)
    }
    
    //MARK: - emoji input and processing
    
    @IBAction func hiddenInputReceived(_ sender: UITextField, forEvent event: UIEvent) {
        let rawEmoji = sender.text!
        sender.text = nil
        
        if rawEmoji == "" { return }
        var emoji = rawEmoji as NSString
        
        let notEmoji = "abcdefghijklmnopqrstuvwxyz1234567890-=!@#$%^&*()_+,./;'[]\\<>?:\"{}| "
        for character in rawEmoji {
            if notEmoji.contains("\(character)".lowercased()) {
                sender.text = ""
                //show an alert
                showOpenKeyboardPopup()
                return
            }
        }
        
        if emoji.length > 1 {
            let char2 = emoji.character(at: 1)
            if char2 >= 57339 && char2 <= 57343
            { //is skin tone marker
                emoji = (rawEmoji as NSString).substring(from: rawEmoji.count - 2) as NSString
            }
            
            if emoji.length % 4 == 0 && emoji.length > 4 { //flags stick together for some reason?
                emoji = emoji.substring(from: emoji.length - 4) as NSString
            }
        }
        
        //track emoji count for rate alert
        if rawEmoji != self.emojiLabel.text {
            emojiCount += 1
            
            if emojiCount == 25 || emojiCount % 50 == 0 {
                if #available(iOS 10.3, *) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        SKStoreReviewController.requestReview()
                        self.hiddenField.resignFirstResponder()
                    }
                }
            }
        }
        
        changeToEmoji(rawEmoji)
    }
    
    func changeToEmoji(_ emoji: String, animate: Bool = true) {
        copyCurrentEmojiToImageView()
        
        emojiLabel.text = emoji
        emojiNameLabel.text = nameForEmoji(emoji)
        
        let primaryColor = colorForImage(imageForEmoji(emoji))
        emojiView.backgroundColor = primaryColor
        let (text, border) = secondaryColorsForBackground(primaryColor)
        emojiNameLabel.textColor = text
        topBar.backgroundColor = border
        self.view.backgroundColor = primaryColor
        
        let backgroundLuma = colorLuma(border)
        let style = backgroundLuma > 0.28 ? UIStatusBarStyle.default : UIStatusBarStyle.lightContent
        UIApplication.shared.setStatusBarStyle(style, animated: true)
        
        if animate {
            animateTransition(usesDifferentColors: !previousEmojiColor.approxEquals(primaryColor))
        }
        previousEmojiColor = primaryColor
    }
    
    func nameForEmoji(_ emoji: String) -> String {
            
        let cfstring = NSMutableString(string: emoji) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstring))
        CFStringTransform(cfstring, &range, kCFStringTransformToUnicodeName, false)
        let capitalName = "\(cfstring)"
        
        if !capitalName.hasPrefix("\\") { //is number emoji
            var splits = capitalName.components(separatedBy: "\\")
            return ((capitalName as NSString).length > 1 ? "keycap " : "") + splits[0]
        }
            
        else {
            var splits = capitalName.components(separatedBy: "}")
            if splits.last == "" { splits.removeLast() }
            
            for i in 0 ..< splits.count {
                if (splits[i] as NSString).length > 3 {
                    splits[i] = (splits[i] as NSString).substring(from: 3).lowercased()
                }
            }
            
            if splits.count == 1 {
                return splits[0]
            }
            
            if splits.count == 2{
                if splits[1].hasPrefix("emoji modifier") || splits[1].hasPrefix("variation selector"){ //skin tone emojis
                    return splits[0]
                }
                else { //flags are awful
                    var flagName = ""
                    for split in splits {
                        let splitNS = split.uppercased() as NSString
                        flagName += splitNS.substring(from: splitNS.length - 1)
                    }
                    
                    if let countryName = countryNameForCode(flagName){
                        flagName = countryName
                    }
                    
                    return flagName + " flag"
                }
            }
        }
        
        if emoji == "👁‍🗨" { return "eye in speech bubble" }
        //still nothing somehow
        return "family" //can only be family as far as I know
    }
    
    func imageForEmoji(_ emojiString: String) -> UIImage {
        let size = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        UIGraphicsBeginImageContext(size.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(size)
        context?.setAllowsAntialiasing(true)
        context?.setShouldAntialias(true)
        
        let emoji = emojiString as NSString
        let font = UIFont.systemFont(ofSize: 75.0)
        let attributes = [NSAttributedStringKey.font : font as AnyObject]
        let drawSize = emoji.boundingRect(with: size.size, options: .usesLineFragmentOrigin, attributes: attributes, context: NSStringDrawingContext()).size
        
        let xOffset = (size.width - drawSize.width) / 2
        let yOffset = (size.height - drawSize.height) / 2
        let drawPoint = CGPoint(x: xOffset, y: yOffset)
        let drawRect = CGRect(origin: drawPoint, size: drawSize)
        emoji.draw(in: drawRect.integral, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func colorForImage(_ uiimage: UIImage) -> UIColor {
        
        guard let image = uiimage.cgImage else { return UIColor.white }
        let pixelData = image.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        typealias Pixel = (red: Int, green: Int, blue: Int)
        func pixelAtPoint(_ x: Int, _ y: Int) -> Pixel {
            let pixelIndex = ((Int(uiimage.size.width) * y) + x) * 4
            let b = Int(data[pixelIndex])
            let g = Int(data[pixelIndex + 1])
            let r = Int(data[pixelIndex + 2])
            return (r, g, b)
        }
        
        func clampInt(_ int: Int, onInterval interval: Int) -> Int {
            return Int(int / interval) * interval
        }
        
        var countMap: [String : (color: Pixel, count: Int)] = [:]
        var maximum: (color: Pixel, count: Int)?
        
        for y in 0 ..< Int(uiimage.size.width) {
            for x in 0 ..< Int(uiimage.size.height) {
                let pixel = pixelAtPoint(x, y)
                
                //ignore if this color is close to grayscale
                let average = (pixel.red + pixel.green + pixel.blue) / 3
                if abs(pixel.red - average) < 5
                    && abs(pixel.green - average) < 5
                    && abs(pixel.red - average) < 5 {
                        continue
                } 
                
                let red = clampInt(pixel.red, onInterval: 20)
                let green = clampInt(pixel.green, onInterval: 20)
                let blue = clampInt(pixel.blue, onInterval: 20)
                let key = "r:\(red) g:\(green) b:\(blue)"
                
                var (_, currentCount) = countMap[key] ?? ((0, 0, 0), 0)
                currentCount += 1
                countMap.updateValue((pixel, currentCount), forKey: key)
                
                if currentCount > (maximum?.count ?? 0) {
                    maximum = (pixel, currentCount)
                }
            }
        }
        
        let color = maximum?.color ?? (red: 255, green: 255, blue: 255)
        return UIColor(red: CGFloat(color.red) / 255.0, green: CGFloat(color.green) / 255.0, blue: CGFloat(color.blue) / 255.0, alpha: 1.0)
    }
    
    func colorLuma(_ color: UIColor) -> CGFloat{
        var r : CGFloat  = 0.0
        var g : CGFloat  = 0.0
        var b : CGFloat  = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        let lumaR : CGFloat = CGFloat(r) * 0.3
        let lumaG : CGFloat = CGFloat(g) * 0.59
        let lumaB : CGFloat = CGFloat(b) * 0.11
        return (lumaR + lumaG + lumaB) / 3
    }
    
    func secondaryColorsForBackground(_ background: UIColor) -> (text: UIColor, border: UIColor) {
        
        var hue : CGFloat  = 0.0
        var sat : CGFloat  = 0.0
        var bright : CGFloat  = 0.0
        background.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        let backgroundLuma = colorLuma(background)
        
        var text = UIColor(hue: hue, saturation: sat, brightness: bright + 0.35, alpha: 1.0)
        let textLuma = colorLuma(text)
        let lumaDiff = abs(textLuma - backgroundLuma)
        if lumaDiff < 0.05 && textLuma > 0.1 {
            text = UIColor(hue: hue, saturation: sat, brightness: bright - 0.35, alpha: 1.0)
        } else if lumaDiff < 0.05 {
            text = UIColor(hue: hue, saturation: sat - 0.5, brightness: bright + 0.5, alpha: 1.0)
        }
        
        let border = UIColor(hue: hue, saturation: sat, brightness: bright - 0.1, alpha: 1.0)
        
        return (text, border)
    }
    
    //MARK: - Transition between emoji
    
    func animateTransition(usesDifferentColors showCircularMask: Bool) {
        
        if showCircularMask {
            let frame = emojiView.frame
            let diameter = min(frame.size.height, frame.size.width) * 2.0
            
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
        }, completion: nil)
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

extension UIColor {
    
    func approxEquals(_ other: UIColor, within: CGFloat = 0.025) -> Bool {
        var thisRed: CGFloat = 0.0
        var thisGreen: CGFloat = 0.0
        var thisBlue: CGFloat = 0.0
        var thisAlpha: CGFloat = 0.0
        self.getRed(&thisRed, green: &thisGreen, blue: &thisBlue, alpha: &thisAlpha)
        
        var otherRed: CGFloat = 0.0
        var otherGreen: CGFloat = 0.0
        var otherBlue: CGFloat = 0.0
        var otherAlpha: CGFloat = 0.0
        other.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: &otherAlpha)
        
        let diffRed = abs(thisRed - otherRed)
        let diffBlue = abs(thisBlue - otherBlue)
        let diffGreen = abs(thisGreen - otherGreen)
        let diffAlpha = abs(thisAlpha - otherAlpha)
        return diffRed < within && diffBlue < within && diffGreen < within && diffAlpha < within
    }
    
}
