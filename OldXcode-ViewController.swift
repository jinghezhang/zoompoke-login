//
//  ViewController.swift
//  newios
//
//  Created by Jinghe Zhang on 8/5/16.
//  Copyright © 2016 Jinghe Zhang. All rights reserved.
//

import UIKit
import Firebase
//import DigitsKit

//class ViewController: UIViewController { //Phone number sign-in
class ViewController: UIViewController, GIDSignInUIDelegate {
//    override func viewDidLoad() {
//        let digitsButton = DGTAuthenticateButton(authenticationCompletion: { (session, error) in
//            // Inspect session/error objects
//        })
//        self.view.addSubview(digitsButton)
//    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        let authButton = DGTAuthenticateButton(authenticationCompletion: { (session: DGTSession?, error: NSError?) in
//            if (session != nil) {
//                // TODO: associate the session userID with your user model
//                let message = "Phone number: \(session!.phoneNumber)"
//                let alertController = UIAlertController(title: "You are logged in!", message: message, preferredStyle: .Alert)
//                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: .None))
//                self.presentViewController(alertController, animated: true, completion: .None)
//            } else {
//                NSLog("Authentication error: %@", error!.localizedDescription)
//            }
//        })
//        authButton.center = self.view.center
//        self.view.addSubview(authButton)
//
//    }//phone number sign-in
    @IBOutlet weak var SignOutButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
     }//google sign-in
    
    //    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    //    // UIViewController.
    //
    //    // Stop the UIActivityIndicatorView animation that was started when the user
    //    // pressed the Sign In button
    //    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
    //        myActivityIndicator.stopAnimating()
    //    }
    //
    //    // Present a view that prompts the user to sign in with Google
    //    func signIn(signIn: GIDSignIn!,
    //                presentViewController viewController: UIViewController!) {
    //        self.presentViewController(viewController, animated: true, completion: nil)
    //    }
    //
    //    // Dismiss the "Sign in with Google" view
    //    func signIn(signIn: GIDSignIn!,
    //                dismissViewController viewController: UIViewController!) {
    //        self.dismissViewControllerAnimated(true, completion: nil)
    //    }

//Note: When users silently sign in, the Sign-In SDK automatically acquires access tokens and automatically refreshes them when necessary. If you need the access token and want the SDK to automatically handle refreshing it, you can use the getAccessTokenWithHandler: method. To explicitly refresh the access token, call the refreshAccessTokenWithHandler: method.
    
    
    
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        print("you've signed out")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

