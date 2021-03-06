//
//  AppDelegate.swift
//  newios
//
//  Created by Jinghe Zhang on 8/5/16.
//  Copyright © 2016 Jinghe Zhang. All rights reserved.
//

import UIKit
import Firebase
//import GoogleSignIn
//import Fabric
//import DigitsKit

@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?

//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Phone number sign-in
//        // Override point for customization after application launch.
//        Fabric.with([Digits.self])
//        return true
//    }
    
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Google Sign-in
        // Initialize sign-in
        //var configureError: NSError?
        //GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
//        GIDSignIn.sharedInstance().clientID = "899156690028-tq2g6obhr893u2rldlbilphidl8d7vii.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().delegate = self
//        return true
    
//    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //GIDSignIn.sharedInstance().clientID = "899156690028-tq2g6obhr893u2rldlbilphidl8d7vii.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        return true

    }
    
    func application(_ app: UIApplication, open url: URL, options: [String : AnyObject] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //Google Sign-in, for your app to run on iOS 8 and older,
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!, UIApplicationOpenURLOptionsAnnotationKey: annotation]
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            print("you've signed in")
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
//            print("email is: \(email)")
//            // ...
//            } else {
//                print("\(error.localizedDescription)")
//            }
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            let email = user.profile.email
            print("you've signed in, email is: \(email)")
        }

        let authentication = user.authentication!
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication.idToken),
                                                                     accessToken: (authentication.accessToken))
        // ...
    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
    // ...

        }
    }
    
  //  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
  //      if (error == nil) {
  //          // Perform any operations on signed in user here.
  //          print("you've signed in")
  //          let userId = user.userID                  // For client-side use only!
  //          let idToken = user.authentication.idToken // Safe to send to the server
  //          let fullName = user.profile.name
  //          let givenName = user.profile.givenName
  //          let familyName = user.profile.familyName
  //          let email = user.profile.email
  //          print("email is: \(email)")
  //          // ...
  //      } else {
  //          print("\(error.localizedDescription)")
  //      }
  //  }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    //Note: The Sign-In SDK automatically acquires access tokens, but the access tokens will be refreshed only when you call signIn or signInSilently. To explicitly refresh the access token, call the refreshTokensWithHandler: method. If you need the access token and want the SDK to automatically handle refreshing it, you can use the getTokensWithHandler: method.
    //Important: If you need to pass the currently signed-in user to a backend server, send the user's ID token to your backend server and validate the token on the server.
    
 
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

