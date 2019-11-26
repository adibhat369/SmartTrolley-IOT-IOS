//
//  ViewController.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 28/10/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase



class GoogleSignInViewController: UIViewController, GIDSignInUIDelegate {

    // Google sign in button inside the view
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    //This handles the authentication
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //Google sign in
        print("Google Sign in")
       GIDSignIn.sharedInstance().uiDelegate = self
  }
    
    //Decides which view to appear after authentication
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    //View disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        Auth.auth().removeStateDidChangeListener(handle!);
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
   
   
    
    
    func displayErrorMessage(_errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: _errorMessage, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        print("Inside sign in funcvtion")
        if let error = error {
            print("Error ", error)
            // ...
            return
        }
        print("Signed In")

        self.performSegue(withIdentifier: "loginSegue", sender: self)
        guard let authentication = user.authentication else { return }
        let credential =  GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) -> Void in
            if error != nil {
                print("Problem at signing in with google with error :", error!)
            } else if error == nil {
                print("user successfully signed in through GOOGLE! uid:\(Auth.auth().currentUser!.uid)")
                print("signed in")
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        })
    }

    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var mapViewController: MapViewController
        var setting: InitialSettingViewController
        if(segue.identifier == "loginSegue") {
            mapViewController = segue.destination as! MapViewController
            //controller.delegate = self
            
        }
        if(segue.identifier == "FirstSetting") {
            setting = segue.destination as! InitialSettingViewController
            //controller.delegate = self
            
        }
    }

}


