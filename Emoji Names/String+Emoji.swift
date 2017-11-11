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
        
        // some don't have proper names or are too complicated, so override them with custom strings
        let customOverrides = [
            "👁‍🗨": "eye in speech bubble",
            "🏴󠁧󠁢󠁥󠁮󠁧󠁿": "England",
            "🏴󠁧󠁢󠁳󠁣󠁴󠁿": "Scotland",
            "🏴󠁧󠁢󠁷󠁬󠁳󠁿": "Wales",
            "👨‍❤️‍💋‍👨": "kiss",
            "👩‍❤️‍💋‍👩": "kiss",
            "👩‍❤️‍👩": "couple with heart",
            "👨‍❤️‍👨": "couple with heart"
        ]
        
        if let customOverride = customOverrides[self] {
            return customOverride
        }
        
        //special treatment for family composition emoji
        if splits.filter({ !["man", "woman", "girl", "boy"].contains($0) }).count == 0 {
            return "family"
        }
        
        //if all else failed, just string together the names of the individual pieces
        let stitchedName = splits.reduce("") { result, split in
            if result.isEmpty { return split }
            else {
                return result + ", " + split
            }
        }
        
        // ONE LAST THING: lot of the profession emoji are just gender + some object, so fix those
        let stitchedOverrides = [
            "woman, staff of aesculapius": "female doctor",
            "man, staff of aesculapius": "male doctor",
            "woman, ear of rice": "female farmer",
            "man, ear of rice": "male farmer",
            "woman, cooking": "female chef",
            "man, cooking": "male chef",
            "woman, graduation cap": "woman graduating",
            "man, graduation cap": "man graduating",
            "woman, microphone": "female singer",
            "man, microphone": "male singer",
            "woman, school": "female teacher",
            "man, school": "male teacher",
            "woman, factory": "female factory worker",
            "man, factory": "male factory worker",
            "woman, personal computer": "female technologist",
            "man, personal computer": "male technologist",
            "woman, briefcase": "businesswoman",
            "man, briefcase": "businessman",
            "woman, wrench": "female mechanic",
            "man, wrench": "male mechanic",
            "woman, microscope": "female scientist",
            "man, microscope": "male scientist",
            "woman, artist palette": "female artist",
            "man, artist palette": "male artist",
            "woman, fire engine": "female firefighter",
            "man, fire engine": "male firerighter",
            "woman, airplane": "female pilot",
            "man, airplane": "male pilot",
            "woman, rocket": "female astronaut",
            "man, rocket": "male astrnaut",
            "woman, scales": "female judge",
            "man, scales": "male judge"
        ]
        
        if let stitchedOverride = stitchedOverrides[stitchedName] {
            return stitchedOverride
        } else {
            return stitchedName
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
