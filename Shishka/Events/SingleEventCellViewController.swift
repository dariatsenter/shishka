//
//  SingleEventCellViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/25/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class SingleEventCellViewController: UIViewController {
    var storageRef: StorageReference!
    var db: Firestore!
    
    @IBOutlet weak var companyNameOutlet: UILabel!
    @IBOutlet weak var eventNameOutlet: UILabel!
    @IBOutlet weak var eventDescriptionOutlet: UILabel!
    @IBOutlet weak var eventImageOutlet: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var companyName: String = ""
    var eventName: String = ""
    var eventAddress: String = ""
    var eventDescription: String = ""
    var eventTime: String = ""
    var downloadURL: String = ""
    var documentID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.companyNameOutlet.text = self.companyName
        self.companyNameOutlet.sizeToFit()
        self.eventNameOutlet.text = self.eventName
        self.eventNameOutlet.sizeToFit()
        self.eventDescriptionOutlet.text = self.eventDescription
        self.eventDescriptionOutlet.sizeToFit()
        
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
        let eventImageRef = storageRef.child("images/\(self.documentID)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        eventImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.eventImageOutlet.image = image
            }
        }
    }

    @IBAction func signUpUserForEvent(_ sender: Any) {
        //connect to firestore
        //add user id to usersComing attribute of the event
        //once user is signed make the button "unsignup"
        let userID : String = (Auth.auth().currentUser?.uid)!
        print("userId in sugnUpUserForEvent of SingleEventCellViewController is \(userID)")
        if (self.signUpButton.currentTitle == "Пойти на мероприятие"){
            db.collection("events").document(self.documentID).updateData(["usersGoing" : FieldValue.arrayUnion([userID])]) { err in
                if let e = err {
                    print("Error updating document: \(e)")
                } else {
                    print("Added user \(userID) to the goingUsers attribute of event")
                    self.signUpButton.setTitle("Не смогу пойти", for: .normal)
                }
            }
            
        } else{
            db.collection("events").document(self.documentID).updateData(["usersGoing" : FieldValue.arrayRemove([userID])]) {err in
                if let e = err {
                    print("Error deleting user from usersGoing: \(e)")
                } else {
                    print("Removed user \(userID) from goingUsers attribute of event")
                    self.signUpButton.setTitle("Пойти на мероприятие", for: .normal)
                }
            }
        }
    }
    
}
