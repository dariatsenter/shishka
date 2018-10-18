//
//  ViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 8/14/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoImage.image = UIImage(named: "likey")
    }

    @IBAction func loginPressed(_ sender: Any) {
        loginUser()
    }
    
    func loginUser(){
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
                user, error in
            if (error != nil){
                print("no user found")

            } else  {
                print("success, logged in as \(String(describing: user?.user.email))")
                //Transition to other view
//                let storyboard = UIStoryboard(name: "Main", bundle:nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "loggedInVC") as! UITabBarController
//                self.present(vc, animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}

