//
//  AppDelegate.swift
//  dex
//
//  Created by AJ Caldwell on 12/19/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
        return true
    }

    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
        return true
    }
}
