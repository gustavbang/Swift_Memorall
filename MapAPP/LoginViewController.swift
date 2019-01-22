//
//  LoginViewController.swift
//  MapAPP
//
//  Created by admin on 20/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginPressed(_ sender: UIButton) {
        //Get default of UI Object
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            return
        }
        
        //Set ourselves as the delegate
        authUI?.delegate = self

        //Get a reference to the UI view controller
        let authViewController = authUI!.authViewController()
        
        //Show it
        present(authViewController, animated: true, completion: nil)
    }

}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        //Check if there is an error (Error is 0 means no errors)
        if error != nil {
            //Log error
            return
        }
        
        //authDataResult?.user.uid
        
        performSegue(withIdentifier: "goHome", sender: self)
    }
}
