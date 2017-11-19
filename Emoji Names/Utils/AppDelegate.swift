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
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if (window?.rootViewController as? EmojiViewController)?.hiddenField.isFirstResponder == false {
            (window?.rootViewController as? EmojiViewController)?.showKeyboard()
        }
    }

}
