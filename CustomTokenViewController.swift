//
//  ViewController.swift
//  newios
//
//  Created by Jinghe Zhang on 8/5/16.
//  Copyright © 2016 Jinghe Zhang. All rights reserved.
//

import UIKit

// [START auth_view_import]
import FirebaseAuth
// [END auth_view_import]

@objc(CustomTokenViewController)
class CustomTokenViewController: UIViewController {
    
    @IBOutlet weak var tokenField: UITextView!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapCustomTokenLogin(sender: AnyObject) {
        let customToken = tokenField.text
        showSpinner({
            // [START signinwithcustomtoken]
            FIRAuth.auth()?.signIn(withCustomToken: customToken!) { (user, error) in
                // [START_EXCLUDE]
                self.hideSpinner({
                    if let error = error {
                        self.showMessagePrompt(error.localizedDescription)
                        return
                    }
                    self.navigationController!.popViewController(animated: true)
                })
                // [END_EXCLUDE]
            }
            // [END signinwithcustomtoken]
        })
    }
    
}
