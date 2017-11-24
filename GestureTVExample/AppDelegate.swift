//
//  AppDelegate.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/03.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import GestureTV
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        _ = TouchManager.shared // init
        TouchManager.shared.isDebugEnabled = true

        return true
    }
}
