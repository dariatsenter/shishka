//
//  SingleBarterViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 11/9/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

class SingleBarterViewController: UIViewController {
    var storageRef: StorageReference!
    var db: Firestore!
    
    @IBOutlet weak var companyNameOutlet: UILabel!
    @IBOutlet weak var productNameOutlet: UILabel!
    @IBOutlet weak var productDescriptionOutlet: UILabel!
    @IBOutlet weak var productImageOutlet: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var companyName: String = ""
    var productName: String = ""
    var productAddress: String = ""
    var productDescription: String = ""
    var productConditions: String = ""
    var isDelivery: Bool = false
    var downloadURL: String = ""
    var documentID: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyNameOutlet.text = self.companyName
        self.companyNameOutlet.sizeToFit()
        self.productNameOutlet.text = self.productName
        self.productNameOutlet.sizeToFit()
        self.productDescriptionOutlet.text = self.productDescription
        self.productDescriptionOutlet.sizeToFit()
        
        // Firestore and storage setup
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        self.loadImage()
        
        self.companyNameOutlet.sizeToFit()
    }
    
    func loadImage(){
        let barterImageRef = storageRef.child("images/\(self.documentID)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        barterImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.productImageOutlet.image = image
            }
        }
    }
    
    @IBAction func showPopupTapped(_ sender: Any) {
        if (self.signUpButton.currentTitle == "Принять бартер"){
            print("in showPopup")
            showPopup()
        }else {
            signUpUserForBarter()
        }
    }
    
    func showPopup(animated: Bool = true) {
        let the_title = "Подтвердите ответственность"
        let message = "Данным действием вы обязуетесь выполнить условия компании, при их наличии. В случае сильных задержек и невыполнения условий бартера информация будет передана компании и, при двух и более жалобах, доступ пользователя к приложению будет остановлен."
        let popup = PopupDialog(title: the_title, message: message)
        
        let buttonOne = CancelButton(title: "Отменить") {
            print("You canceled barter.")
        }
        
        let buttonTwo = DefaultButton(title: "Согласиться", height: 60) {
            print("Confirmed")
            self.signUpUserForBarter()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        
        self.present(popup, animated: animated, completion: nil)
    }
    
    func signUpUserForBarter() {
        let userID : String = (Auth.auth().currentUser?.uid)!
        if (self.signUpButton.currentTitle == "Принять бартер"){
            self.db.collection("barter").document(self.documentID).updateData(["usersRequested" : FieldValue.arrayUnion([userID])], completion: {err in
                if let e = err {
                    print("Error updating document: \(e)")
                } else {
                    print("Added user \(userID) to the usersRequested attribute of barter")
                    self.signUpButton.setTitle("Отменить бартер", for: .normal)
                }
            })
        } else{
            self.db.collection("barter").document(self.documentID).updateData(["usersRequested" : FieldValue.arrayRemove([userID])], completion: {err in
                if let e = err {
                    print("Error deleting user from usersRequested: \(e)")
                } else {
                    print("Removed user \(userID) from usersRequesteed attribute of barter")
                    self.signUpButton.setTitle("Принять бартер", for: .normal)
                }
            })
        }
    }
    
}
