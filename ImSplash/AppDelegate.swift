//
//  AppDelegate.swift
//  ImSplash
//
//  Created by Lam Pham on 4/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let allowsMultipleSelection = true
            let configuration = UnsplashPhotoPickerConfiguration(
                accessKey: "ztktvGi3z8qcJUqfzX1-SZ2akBIGMO9jvMufCcMrNOM",
                secretKey: "vmgtCwy1EUkhKA9wtlL7-ybDdH1QrY0jNyUaeL42z8w",
                query: "viet nam",
                allowsMultipleSelection: allowsMultipleSelection
            )
        
        let vc = HomeViewController.instantiateFromNib()
        Configuration.shared = configuration
        let nav = UINavigationController(rootViewController: vc)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }

 

}

