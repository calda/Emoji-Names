//
//  Event.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Fabric
import Crashlytics

// MARK: Event

enum Event {
    
    case appLaunched
    
    case emojiViewed(String)
    case textPasted(emojiCount: Int)
    case emojiPasted(String)
    case emojiStyleUpdated(EmojiStyle)
    
    case shareEmojiTapped(emoji: String)
    case imageColorChanged
    case imageEmojiNameToggled
    case imageEmojiStyleToggled
    case imageShared(emoji: String, hasCustomColor: Bool, showingName: Bool, style: EmojiStyle)
    
}

// MARK: Event+Fabric

extension Event {
    
    func record() {
        Answers.logCustomEvent(withName: eventName, customAttributes: customAttributes)
    }
    
    private var eventName: String {
        switch(self) {
        case .appLaunched: return "App Launched"
        case .emojiViewed(_): return "Emoji Viewed"
        case .textPasted(_): return "Text Pasted"
        case .emojiPasted(_): return "Emoji Pasted"
        case .emojiStyleUpdated(_): return "Emoji Style Updated"
        case .shareEmojiTapped(_): return "Share Emoji Tapped"
        case .imageColorChanged: return "Image Color Changed"
        case .imageEmojiNameToggled: return "Image Emoji Name Toggled"
        case .imageEmojiStyleToggled: return "Image Emoji Style Toggled"
        case .imageShared(_): return "Image Shared"
        }
    }
    
    private var customAttributes: [String: Any]? {
        switch(self) {
        case .emojiViewed(let emoji):
            return ["Emoji": emoji]
        case .textPasted(let emojiCount):
            return ["Emoji Count": emojiCount]
        case .emojiPasted(let emoji):
            return ["Emoji": emoji]
        case .emojiStyleUpdated(let style):
            return ["Emoji Style": style.stringValue]
        case .shareEmojiTapped(let emoji):
            return ["Emoji": emoji]
        case .imageShared(let emoji, let hasCustomColor, let showingName, let style):
            return [
                "Emoji": emoji,
                "Has Custom Color": hasCustomColor.stringValue,
                "Showing Name": showingName.stringValue,
                "Emoji Style": style.stringValue]
        default:
            return nil
        }
    }
    
}

extension Bool {
    var stringValue: String {
        return self ? "true" : "false"
    }
}
