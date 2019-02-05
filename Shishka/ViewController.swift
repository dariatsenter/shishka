//
//  ViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 8/14/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class ViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginTransitionButton: TransitionButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(loginTransitionButton)
        
        loginTransitionButton.backgroundColor = .black
        loginTransitionButton.setTitle("логин", for: .normal)
        loginTransitionButton.cornerRadius = 10
        loginTransitionButton.spinnerColor = .white
//        loginTransitionButton.addTarget(self, action: #selector(loginTransitionButton(_:)), for: .touchUpInside)
        
        self.hideKeyboardWhenTappedAround()
        self.logoImage.image = UIImage(named: "likey")
    }

//    @IBAction func loginPressed(_ sender: Any) {
//        loginUser()
//    }
    func loginTransitionButton(_ button: TransitionButton, loginStyle: StopAnimationStyle) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
        
            sleep(2) // 3: Do your networking task or background work here.
            
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                button.stopAnimation(animationStyle: loginStyle, completion: {
//                    let secondVC = UIViewController()
//                    self.present(secondVC, animated: true, completion: nil)
                    if (loginStyle == .expand){
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else { return }
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            })
        })
    }
    
    @IBAction func requestAccessPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return }
        print(vc, self.navigationController)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginUser() -> Void {
        print("hey is loginUser() called once")
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
                user, error in
            if (error != nil){
                print("no user found")
                self.loginTransitionButton(self.loginTransitionButton, loginStyle: .shake)
            } else  {
                print("success, logged in as \(String(describing: user?.user.email))")
                self.loginTransitionButton(self.loginTransitionButton, loginStyle: .expand)
                //user logged in
//                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else { return }
//                self.navigationController?.popToRootViewController(animated: true)
//
//                self.present(vc, animated: true, completion: nil)
            }
        })
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
