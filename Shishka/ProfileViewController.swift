//
//  ProfileViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/23/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var numberOfEvents: UILabel!
    @IBOutlet weak var numberOfBarters: UILabel!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.signOutButton.layer.cornerRadius = 10
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.clipsToBounds = true
        
        self.getProfilePicture()
        
        self.setNumberOfEventsAndBarters()
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        //return to login page
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    func getProfilePicture() {
        //TEMPORARY INSTERTING MY OWN ACCESS TOKEN
        let urlString = "https://api.instagram.com/v1/users/self/?access_token=20388052.5ce06e6.0e454919af884730b6a73fa01f897642"
//            UserDefaults.standard.string(forKey: "instagramAccessToken")!
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = data as! NSDictionary
                print("this is json data \(json)")
                dump(json)
                
                let jsonData = json["data"] as? NSDictionary
                let profilePic = jsonData!["profile_picture"]
                print("this is profilePic \(profilePic!)")
                self.donwloadAndSetProfilePicture(profileLink: profilePic as! String)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func donwloadAndSetProfilePicture(profileLink: String) {
        let picURL = URL(string: profileLink)
        let session = URLSession.shared
        let downloadPicTask = session.dataTask(with: picURL!) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading profile picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
//                    print("Downloaded profile picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        self.profilePicture.image = UIImage(data: imageData)
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    func setNumberOfEventsAndBarters() {
        let userID : String = (Auth.auth().currentUser?.uid)!
        print("in setNumberOfEventsAndBarters of ProfileViewController userID is \(userID)")
        let docRef = db.collection("users").document(userID)
        var numEvents = 0, numBarters = 0
    
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                for event in document.data()?["userEvents"] as? [String] ?? [] {
                    if event != "" {
                        numEvents = +1
                    }
                }
                for barter in document.data()?["userBarters"] as? [String] ?? [] {
                    if barter != "" {
                        numBarters = +1
                    }
                }
                self.numberOfEvents.text = String(numEvents)
                self.numberOfBarters.text = String(numBarters)
            } else {
                print("Document does not exist")
            }
        }
    }
    
}
