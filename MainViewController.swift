//
//  ViewController.swift
//  newios
//
//  Created by Jinghe Zhang on 8/5/16.
//  Copyright © 2016 Jinghe Zhang. All rights reserved.
//

import UIKit

// [START usermanagement_view_import]
import Firebase
// [END usermanagement_view_import]
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit

@objc(MainViewController)
class MainViewController: UITableViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let kSectionToken = 3
    let kSectionProviders = 2
    let kSectionUser = 1
    let kSectionSignIn = 0
    
    enum AuthProvider {
        case AuthEmail
        case AuthAnonymous
        case AuthFacebook
        case AuthGoogle
        case AuthTwitter
        case AuthCustom
    }
    
    /*! @var kOKButtonText
     @brief The text of the "OK" button for the Sign In result dialogs.
     */
    let kOKButtonText = "OK"
    
    /*! @var kTokenRefreshedAlertTitle
     @brief The title of the "Token Refreshed" alert.
     */
    let kTokenRefreshedAlertTitle = "Token"
    
    /*! @var kTokenRefreshErrorAlertTitle
     @brief The title of the "Token Refresh error" alert.
     */
    let kTokenRefreshErrorAlertTitle = "Get Token Error"
    
    /** @var kSetDisplayNameTitle
     @brief The title of the "Set Display Name" error dialog.
     */
    let kSetDisplayNameTitle = "Set Display Name"
    
    /** @var kUnlinkTitle
     @brief The text of the "Unlink from Provider" error Dialog.
     */
    let kUnlinkTitle = "Unlink from Provider"
    
    /** @var kChangeEmailText
     @brief The title of the "Change Email" button.
     */
    let kChangeEmailText = "Change Email"
    
    /** @var kChangePasswordText
     @brief The title of the "Change Password" button.
     */
    let kChangePasswordText = "Change Password"
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: FIRAuthStateDidChangeListenerHandle?

    func showAuthPicker(providers: [AuthProvider]) {
        let picker = UIAlertController(title: "Select Provider",
                                       message: nil,
                                       preferredStyle: .actionSheet)
        for provider in providers {
            var action : UIAlertAction
            switch(provider) {
            case .AuthEmail:
                action = UIAlertAction(title: "Email", style: .default, handler: { (UIAlertAction) in
                    self.performSegue(withIdentifier: "email", sender:nil)
                })
            case .AuthCustom:
                action = UIAlertAction(title: "Custom", style: .default, handler: { (UIAlertAction) in
                    self.performSegue(withIdentifier: "customToken", sender: nil)
                })
            case .AuthAnonymous:
                action = UIAlertAction(title: "Anonymous", style: .default, handler: { (UIAlertAction) in
                    self.showSpinner({
                        // [START firebase_auth_anonymous]
                        FIRAuth.auth()?.signInAnonymously() { (user, error) in
                            // [START_EXCLUDE]
                            self.hideSpinner({
                                if let error = error {
                                    self.showMessagePrompt(error.localizedDescription)
                                    return
                                }
                            })
                            // [END_EXCLUDE]
                        }
                        // [END firebase_auth_anonymous]
                    })
                    
                })
            case .AuthFacebook:
                action = UIAlertAction(title: "Facebook", style: .default, handler: { (UIAlertAction) in
                    let loginManager = FBSDKLoginManager()
                    loginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                        } else if(result?.isCancelled)! {
                            print("FBLogin cancelled")
                        } else {
                            // [START headless_facebook_auth]
                            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                            // [END headless_facebook_auth]
                            self.firebaseLogin(credential: credential)
                        }
                    })
                })
            case .AuthGoogle:
                action = UIAlertAction(title: "Google", style: .default, handler: { (UIAlertAction) in
                    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
                    GIDSignIn.sharedInstance().uiDelegate = self
                    GIDSignIn.sharedInstance().delegate = self
                    GIDSignIn.sharedInstance().signIn()
                    // Uncomment to automatically sign in the user.
                    //GIDSignIn.sharedInstance().signInSilently()
                })
            case .AuthTwitter:
                action = UIAlertAction(title: "Twitter", style: .default, handler: { (UIAlertAction) in
                    Twitter.sharedInstance().logIn() { (session, error) in
                        if let session = session {
                            // [START headless_twitter_auth]
                            let credential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                            // [END headless_twitter_auth]
                            self.firebaseLogin(credential: credential)
                        } else {
                            self.showMessagePrompt((error?.localizedDescription)!)
                        }
                    }
                })
            }
            picker.addAction(action)
        }
        
        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(picker, animated: true, completion: nil)
        
    }
        
    @IBAction func didTapSignIn(sender: AnyObject) {
        showAuthPicker(providers: [
            AuthProvider.AuthEmail,
            AuthProvider.AuthAnonymous,
            AuthProvider.AuthGoogle,
            AuthProvider.AuthFacebook,
            AuthProvider.AuthTwitter,
            AuthProvider.AuthCustom
            ])
    }
    
    @IBAction func didTapLink(sender: AnyObject) {
        var providers = Set([
            AuthProvider.AuthGoogle,
            AuthProvider.AuthFacebook,
            AuthProvider.AuthTwitter
            ])
        // Remove any existing providers. Note that this is not a complete list of
        // providers, so always check the documentation for a complete reference:
        // https://firebase.google.com/docs/auth
        let user = FIRAuth.auth()?.currentUser
        for info in (user?.providerData)! {
            if (info.providerID == FIRTwitterAuthProviderID) {
                providers.remove(AuthProvider.AuthTwitter)
            } else if (info.providerID == FIRFacebookAuthProviderID) {
                providers.remove(AuthProvider.AuthFacebook)
            } else if (info.providerID == FIRGoogleAuthProviderID) {
                providers.remove(AuthProvider.AuthGoogle)
            }
        }
        showAuthPicker(providers: Array(providers))
    }
    
    func setTitleDisplay(user: FIRUser?) {
        if let name = user?.displayName {
            self.navigationItem.title = "Welcome \(name)"
        } else {
            self.navigationItem.title = "Authentication"
        }
    }
    
    func firebaseLogin(credential: FIRAuthCredential) {
        showSpinner({
            if let user = FIRAuth.auth()?.currentUser {
                // [START link_credential]
                user.link(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                    self.hideSpinner({
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                            return
                        }
                        self.tableView.reloadData()
                    })
                    // [END_EXCLUDE]
                }
                // [END link_credential]
            } else {
                // [START signin_credential]
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                    self.hideSpinner({
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                            return
                        }
                    })
                    // [END_EXCLUDE]
                }
                // [END signin_credential]
            }
        })
        print("hello.....................\(credential)")
    }
    
    // [START headless_google_auth]
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
            self.showMessagePrompt(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication!
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
        // [START_EXCLUDE]
        firebaseLogin(credential: credential)
        // [END_EXCLUDE]
    }
    // [END headless_google_auth]
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        // [START signout]
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            //print("Error signing out: %@", signOutError)
            self.showMessagePrompt("Error signing out: \(signOutError)")
        }
        GIDSignIn.sharedInstance().signOut()
        self.showMessagePrompt("you've signed out")
        // [END signout]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            self.setTitleDisplay(user: user)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kSectionSignIn:
            return 1
        case kSectionUser, kSectionToken:
            if FIRAuth.auth()?.currentUser != nil {
                return 1
            } else {
                return 0
            }
        case kSectionProviders:
            if let user = FIRAuth.auth()?.currentUser {
                return user.providerData.count
            }
            return 0
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        switch indexPath.section {
        case kSectionSignIn:
            if FIRAuth.auth()?.currentUser != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "SignOut")
                print("\(FIRAuth.auth()?.currentUser?.providerData.count)")
 /*               if FIRAuth.auth()?.currentUser?.isEmailVerified != true {
                    self.showMessagePrompt("User hasn't been verified, you may not have full access to all services. Please request verify email, then check your inbox")
                    // [START send_verification_email]
 /*                   showSpinner({
                    FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                        // [START_EXCLUDE]
                        self.hideSpinner({
                            if let error = error {
                                self.showMessagePrompt(error.localizedDescription)
                                return
                            }
                            self.showMessagePrompt("User hasn't been verified, you may not have full access to all services. Verification email has been sent, please check your inbox, verify and then log in again")
                        })
                        // [END_EXCLUDE]
                    })
                    }) */
                    // [END send_verification_email]
                } */
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "SignIn")
            }
        case kSectionUser:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile")
            let user = FIRAuth.auth()?.currentUser
            let emailLabel = cell?.viewWithTag(1) as! UILabel
            let userIDLabel = cell?.viewWithTag(2) as! UILabel
            let verifiedLabel = cell?.viewWithTag(5) as! UILabel
            let profileImageView = cell?.viewWithTag(3) as! UIImageView
            emailLabel.text = user?.email
            userIDLabel.text = user?.uid
            if user?.isEmailVerified == true {
                verifiedLabel.text = "Verified"
            } else {
                verifiedLabel.text = "Not Verified"
            }

            
            
            let photoURL = user?.photoURL
            struct last {
                static var photoURL: NSURL? = nil
            }
            last.photoURL = photoURL;  // to prevent earlier image overwrites later one.
            if let photoURL = photoURL {
                DispatchQueue.global().async{
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),{
                //DispatchQueue.global(attributes: .qosUserInitiated).async
                    let data = NSData.init(contentsOf: photoURL)
                    if let data = data {
                        let image = UIImage.init(data: data as Data)
                        //dispatch_async(dispatch_get_main_queue(),
                        DispatchQueue.main.async{
                            if (photoURL == last.photoURL) {
                                profileImageView.image = image
                            }
                        }
                        //)
                    }
                }
                //)
            } else {
                profileImageView.image = UIImage.init(named: "ic_account_circle")
            }
        case kSectionProviders:
            cell = tableView.dequeueReusableCell(withIdentifier: "Provider")
            let userInfo = FIRAuth.auth()?.currentUser?.providerData[indexPath.row]
            cell?.textLabel?.text = userInfo?.email
            //cell?.detailTextLabel?.text = userInfo?.uid
            //cell?.textLabel?.text = FIRAuth.auth()?.currentUser?.email
            if FIRAuth.auth()?.currentUser?.isEmailVerified == true {
                cell?.detailTextLabel?.text = "Verified"
            } else {
                cell?.detailTextLabel?.text = "Not Verified"
            }
        case kSectionToken:
            cell = tableView.dequeueReusableCell(withIdentifier: "Token")
            let requestEmailButton = cell?.viewWithTag(4) as! UIButton
            requestEmailButton.isEnabled = (FIRAuth.auth()?.currentUser?.email != nil) ? true : false
            
        default:
            cell = nil
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unlink"
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == kSectionProviders {
            return .delete
        }
        return .none
    }
    
    // Swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let providerID = FIRAuth.auth()?.currentUser?.providerData[indexPath.row].providerID
            showSpinner({
                // [START unlink_provider]
                FIRAuth.auth()?.currentUser?.unlink(fromProvider: providerID!) { (user, error) in
                    // [START_EXCLUDE]
                    self.hideSpinner({
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                            return
                        }
                        tableView.reloadData()
                    })
                    // [END_EXCLUDE]
                }
                // [END unlink_provider]
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionUser {
            return 200
        }
        return 44
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    @IBAction func didTokenRefresh(sender: AnyObject) {
        let action: FIRAuthTokenCallback = {(token, error) in
            let okAction = UIAlertAction.init(title: self.kOKButtonText, style: .default)
            {action in print(self.kOKButtonText)}
            if let error = error {
                let alertController  = UIAlertController.init(title: self.kTokenRefreshErrorAlertTitle,
                                                              message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Log token refresh event to Scion.
            FIRAnalytics.logEvent(withName: "tokenrefresh", parameters: nil)
            
            let alertController = UIAlertController.init(title: self.kTokenRefreshedAlertTitle,
                                                         message: token, preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // [START token_refresh]
        FIRAuth.auth()?.currentUser?.getTokenForcingRefresh(true, completion: action)
        // [END token_refresh]
    }
    
    /** @fn setDisplayName
     @brief Changes the display name of the current user.
     */
    @IBAction func didSetDisplayName(sender: AnyObject) {
        showTextInputPrompt(withMessage: "Display Name:") { (userPressedOK, userInput) in
            if let userInput = userInput {
                self.showSpinner({
                    // [START profile_change]
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = userInput
                    changeRequest?.commitChanges() { (error) in
                        // [END profile_change]
                        self.hideSpinner({
                            self.showTypicalUIForUserUpdateResultsWithTitle(resultsTitle: self.kSetDisplayNameTitle, error: error)
                            self.setTitleDisplay(user: FIRAuth.auth()?.currentUser)
                        })
                    }
                })
            } else {
                self.showMessagePrompt("displayname can't be empty")
            }
        }
    }
    
    /** @fn requestVerifyEmail
     @brief Requests a "verify email" email be sent.
     */
    @IBAction func didRequestVerifyEmail(sender: AnyObject) {
        showSpinner({
            // [START send_verification_email]
            FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                // [START_EXCLUDE]
                self.hideSpinner({
                    if let error = error {
                        self.showMessagePrompt(error.localizedDescription)
                        return
                    }
                    self.showMessagePrompt("Sent")
                })
                // [END_EXCLUDE]
            })
            // [END send_verification_email]
        })
    }
    
    /** @fn changeEmail
     @brief Changes the email address of the current user.
     */
    @IBAction func didChangeEmail(sender: AnyObject) {
 /*       showTextInputPrompt(withMessage: "Email Address:") { (userPressedOK, userInput) in
            if let userInput = userInput {
                self.showSpinner({
                    // [START change_email]
                    FIRAuth.auth()?.currentUser?.updateEmail(userInput) { (error) in
                        // [START_EXCLUDE]
                        self.hideSpinner({
                            self.showTypicalUIForUserUpdateResultsWithTitle(resultsTitle: self.kChangeEmailText, error:error)
                        })
                        // [END_EXCLUDE]
                    }
                    // [END change_email]
                })
            } else {
                self.showMessagePrompt("email can't be empty")
            }
        }
 */
        showTextInputPrompt(withMessage: "Email:") { (userPressedOK, email) in
            if let email = email {
                self.showTextInputPrompt(withMessage: "Password:") { (userPressedOK, password) in
                    if let password = password {
                        self.showSpinner({
                            // [START create_user]
                            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                                // [START_EXCLUDE]
                                self.hideSpinner({
                                    if let error = error {
                                        self.showMessagePrompt(error.localizedDescription)
                                        return
                                    } else {
                                        self.showMessagePrompt("Login email successfully changed")
                                    }
                                    self.navigationController!.popViewController(animated: true)
                                })
                                // [END_EXCLUDE]
                            }
                            // [END create_user]
                        })
                    } else {
                        self.showMessagePrompt("password can't be empty")
                    }
                }
            } else {
                self.showMessagePrompt("email can't be empty")
            }
        }
        
        
        
    }
    
    /** @fn changePassword
     @brief Changes the password of the current user.
     */
    @IBAction func didChangePassword(sender: AnyObject) {
        showTextInputPrompt(withMessage: "New Password:") { (userPressedOK, userInput) in
            if let userInput = userInput {
                self.showSpinner({
                    // [START change_password]
                    FIRAuth.auth()?.currentUser?.updatePassword(userInput) { (error) in
                        // [START_EXCLUDE]
                        self.hideSpinner({
                            self.showTypicalUIForUserUpdateResultsWithTitle(resultsTitle: self.kChangePasswordText, error:error)
                        })
                        // [END_EXCLUDE]
                    }
                    // [END change_password]
                })
            } else {
                self.showMessagePrompt("password can't be empty")
            }
        }
    }
    
    // MARK: - Helpers
    
    /** @fn showTypicalUIForUserUpdateResultsWithTitle:error:
     @brief Shows a @c UIAlertView if error is non-nil with the localized description of the error.
     @param resultsTitle The title of the @c UIAlertView
     @param error The error details to display if non-nil.
     */
    func showTypicalUIForUserUpdateResultsWithTitle(resultsTitle: String, error: NSError?) {
        if let error = error {
            let message = "\(error.domain) (\(error.code))\n\(error.localizedDescription)"
            let okAction = UIAlertAction.init(title: self.kOKButtonText, style: .default)
            {action in print(self.kOKButtonText)}
            let alertController  = UIAlertController.init(title: resultsTitle,
                                                          message: message, preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        tableView.reloadData()
    }
    
}
