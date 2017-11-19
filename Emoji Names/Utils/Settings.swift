//
//  Settings.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/17/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation

struct Setting {
    
    static let preferredEmojiStyle = EnumSetting("preferredEmojiStyle", default: EmojiStyle.system)
    
    // MARK: Setting struct
    
    struct Setting<ValueType> {
        fileprivate let key: String
        fileprivate let defaultValue: ValueType
        
        fileprivate init(_ key: String, default: ValueType) {
            if `default` is EnumType { fatalError("You should be using SettingWithEnumValue") }
            self.key = key
            self.defaultValue = `default`
        }
        
        func update(to newValue: ValueType?) {
            UserDefaults.standard.setValue(newValue ?? defaultValue, forKey: self.key)
        }
        
        var value: ValueType {
            return UserDefaults.standard.value(forKey: key) as? ValueType ?? defaultValue
        }
    }
    
    // MARK: Setting+Enum struct
    
    struct EnumSetting<ValueType: EnumType> {
        fileprivate let key: String
        fileprivate let defaultValue: ValueType
        
        fileprivate init(_ key: String, default: ValueType) {
            self.key = key
            self.defaultValue = `default`
        }
        
        func update(to newValue: ValueType?) {
            UserDefaults.standard.setValue(newValue?.rawValue ?? defaultValue.rawValue, forKey: self.key)
        }
        
        var value: ValueType {
            guard let rawValue = UserDefaults.standard.value(forKey: key) as? String,
                let enumValue = ValueType(rawValue: rawValue) else
            {
                return defaultValue
            }
            
            return enumValue
        }
    }
    
}

public protocol EnumType {
    init?(rawValue: String)
    var rawValue: String { get }
}
