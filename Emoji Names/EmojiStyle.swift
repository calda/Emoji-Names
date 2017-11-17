//
//  EmojiStyle.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/17/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit
import SVGKit

enum EmojiStyle: String, EnumType {
    
    case system
    case twitter
    
    func image(of emoji: String) -> UIImage {
        switch self {
        case .system:
            return generateImageWithSystemFont(for: emoji)
        case .twitter:
            return loadTwemojiImage(for: emoji) ?? generateImageWithSystemFont(for: emoji)
        }
    }
    
    private func loadTwemojiImage(
        for emoji: String,
        size: CGSize = CGSize(width: 100, height: 100)) -> UIImage?
    {
        let codepointStrings = emoji.unicodeScalars.flatMap { scalar -> String? in
            let codepoint = scalar.value
            let hexString = String(format: "%x", codepoint)
            
            //twemoji excludes FE0F (unicode variant selector 16)
            guard hexString != "FE0F" else {
                return nil
            }
            
            return hexString
        }
        
        let expectedVectorName = codepointStrings.joined(separator: "-")
        
        guard Bundle.main.path(forResource: expectedVectorName, ofType: "svg") != nil,
            let vector = SVGKImage(named: "\(expectedVectorName).svg") else
        {
            return nil
        }
        
        vector.size = size
        return vector.uiImage
    }
    
    private func generateImageWithSystemFont(for emojiString: String) -> UIImage {
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
}
