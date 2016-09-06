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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [START firebase_configure]
        // Use Firebase library to configure APIs
        FIRApp.configure()
        // [END firebase_configure]
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions:launchOptions)
        let key = NSBundle.mainBundle().objectForInfoDictionaryKey("consumerKey"),
        secret = NSBundle.mainBundle().objectForInfoDictionaryKey("consumerSecret")
        if let key = key as? String, secret = secret as? String
            where key.characters.count > 0 && secret.characters.count > 0 {
            Twitter.sharedInstance().startWithConsumerKey(key, consumerSecret: secret)
        }
        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, openURL url: NSURL, options: [String : AnyObject])
        -> Bool {
            return self.application(application,
                                    openURL: url,
                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?,
                                    annotation: [:])
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if GIDSignIn.sharedInstance().handleURL(url,
                                                sourceApplication: sourceApplication,
                                                annotation: annotation) {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
}
