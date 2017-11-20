//
//  AppDelegate.swift
//  Emoji Playlist
//
//  Created by DFA Film 9: K-9 on 4/14/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

extension Notification.Name {
    static let appWillResignActive = Notification.Name("appWillResignActive")
    static let appDidEnterBackground = Notification.Name("appDidEnterBackground")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self, Answers.self])
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        (window?.rootViewController as? EmojiViewController)?.hiddenField?.resignFirstResponder()
        (window?.rootViewController as? EmojiViewController)?.updateContentHeight(animate: false)
        
        NotificationCenter.default.post(name: .appWillResignActive, object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: .appDidEnterBackground, object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if (window?.rootViewController as? EmojiViewController)?.hiddenField.isFirstResponder == false {
            (window?.rootViewController as? EmojiViewController)?.showKeyboard()
        }
    }

}
