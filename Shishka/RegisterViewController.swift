//
//  RegisterViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/11/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class RegisterViewController: UIViewController, GIDSignInUIDelegate {

    var db: Firestore!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerLastName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerConfirmEmail: UITextField!
    @IBOutlet weak var registerDOB: UITextField!
    @IBOutlet weak var connectInstagram: UIButton!
    @IBOutlet weak var connectYoutube: UIButton!
    
    private var datePicker: UIDatePicker?
    var instagramConnected: Bool? {
        willSet(newValue) {
            if (newValue == true){
                instagramConnectedAnimation()
            }
        }
    }
    var youtubeConnected: Bool? {
        willSet(newValue) {
            if (newValue == true){
                youtubeConnectedAnimation()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView(_:)), name: NSNotification.Name(rawValue: "youtubeConnectedNotification"), object: nil)

        
        GIDSignIn.sharedInstance().uiDelegate = self

        self.instagramConnected = false
        self.youtubeConnected = false
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegisterViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        registerDOB.inputView = datePicker
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        registerDOB.text = dateFormatter.string(from: datePicker.date)
    }
    @IBAction func senfRequestToServer(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //send the information from the inputs and instagram/youtube to firebase
        db.collection("requestedUsers").addDocument(data: [
            "firstName" : self.registerName.text,
            "lastName" : self.registerLastName.text,
            "email": self.registerEmail.text,
            "DOB": dateFormatter.string(from: (self.datePicker?.date)!),
            "instagramAccessToken": UserDefaults.standard.string(forKey: "instagramAccessToken"),
            "youtubeAccessToken": UserDefaults.standard.string(forKey: "youtubeAccessToken"),
            "youtubeRefreshToken": UserDefaults.standard.string(forKey: "youtubeRefreshToken")
        ]){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ")
            }
        }
    }
    
    //but the GIDSignInButton inside a custom button for style
    @IBAction func customYoutubeButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func instagramConnectedAnimation(){
        self.connectInstagram.setTitle("Instagram подключен", for: .normal)
        self.connectInstagram.backgroundColor = UIColor(red:0.53, green:0.83, blue:0.49, alpha:1.0)
    }
    
    func youtubeConnectedAnimation(){
        self.connectYoutube.setTitle("Youtube подключен", for: .normal)
        self.connectYoutube.backgroundColor = UIColor(red:0.53, green:0.83, blue:0.49, alpha:1.0)
    }
    
    @objc func refreshView(_ notification: Notification) {
        self.connectYoutube.setTitle("Youtube подключен", for: .normal)
        self.connectYoutube.backgroundColor = UIColor(red:0.53, green:0.83, blue:0.49, alpha:1.0)
    }
    
}
