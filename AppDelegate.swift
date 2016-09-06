//
//  AppDelegate.swift
//  newios
//
//  Created by Jinghe Zhang on 8/5/16.
//  Copyright © 2016 Jinghe Zhang. All rights reserved.
//

import UIKit

// [START auth_import]
import Firebase
// [END auth_import]

import GoogleSignIn
import FBSDKCoreKit
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [START firebase_configure]
        // Use Firebase library to configure APIs
        FIRApp.configure()
        // [END firebase_configure]
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions:launchOptions)
        //Fabric.with([Twitter.self])
        let key = Bundle.main.object(forInfoDictionaryKey: "consumerKey")
        let secret = Bundle.main.object(forInfoDictionaryKey: "consumerSecret")
        if let key = key as? String, let secret = secret as? String
            , key.characters.count > 0 && secret.characters.count > 0 {
            Twitter.sharedInstance().start(withConsumerKey: key, consumerSecret: secret)
        }
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [String : AnyObject])
        -> Bool {
            return self.application(application, open: url, sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
}
