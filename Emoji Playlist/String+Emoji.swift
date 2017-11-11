//
//  String+Emoji.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/10/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

extension String {
    
    var isEmoji: Bool {
        guard !isEmpty else {
            return false
        }
        
        let notEmoji = "abcdefghijklmnopqrstuvwxyz1234567890-=!@#$%^&*()_+,./;'[]\\<>?:\"{}| "
        
        for character in self {
            if notEmoji.contains("\(character)".lowercased()) {
                return false
            }
        }
        
        return true
    }
    
    var emojiName: String {
        let cfstring = NSMutableString(string: self) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstring))
        CFStringTransform(cfstring, &range, kCFStringTransformToUnicodeName, false)
        let capitalName = "\(cfstring)"
        
        // handle number emoji
        if !capitalName.hasPrefix("\\") {
            var splits = capitalName.components(separatedBy: "\\")
            return ((capitalName as NSString).length > 1 ? "keycap " : "") + splits[0]
        }
        
        var splits = capitalName.components(separatedBy: "}")
        if splits.last == "" { splits.removeLast() }
        
        // remove "\\N{" from each component
        splits = splits.map { split -> String in
            if (split as NSString).length > 3 {
                return (split as NSString).substring(from: 3).lowercased()
            } else {
                return split
            }
        }
        
        print("\(self): \(splits)")
        
        if splits.count == 1 {
            return splits[0]
        }
        
        // filter out modifiers
        splits = splits.filter { split in
            return !split.hasPrefix("emoji modifier")
                && !split.hasPrefix("variation selector")
                && split != "zero width joiner"
                && split != "female sign"
                && split != "male sign"
        }
        
        // handle flags
        if splits.count == 2 {
            var flagName = ""
            for split in splits {
                flagName += split.replacingOccurrences(of: "regional indicator symbol letter ", with: "").uppercased()
            }
        
            if let countryName = countryNameForCode(flagName){
                return countryName
            }
        }
        
        // some don't have proper names, so override them with custom strings
        let customOverrides = [
            "👁‍🗨": "eye in speech bubble"
        ]
        
        if let customOverride = customOverrides[self] {
            return customOverride
        }
        
        //if all else failed, just string together the names of the individual pieces
        return splits.reduce("") { result, split in
            if result.isEmpty { return split }
            else {
                return result + ", " + split
            }
        }
    }
    
    var emojiImage: UIImage {
        let size = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        UIGraphicsBeginImageContext(size.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(size)
        context?.setAllowsAntialiasing(true)
        context?.setShouldAntialias(true)
        
        let emoji = self as NSString
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
