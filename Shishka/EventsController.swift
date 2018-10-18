//
//  EventsController.swift
//  Shishka
//
//  Created by Daria Tsenter on 8/15/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "cellId"

class EventsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var collectionViewDelegate: UICollectionViewDelegate?
    //store events from firestore here
    private var eventsArray: [Event] = []
    var db: Firestore!
    var storageRef: StorageReference!
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewOutlet.delegate = self
        self.collectionViewOutlet.dataSource = self
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        loadEvents()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("size of array is \(self.eventsArray.count)")
        return self.eventsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! EventCollectionViewCell
        cell.eventName.text = self.eventsArray[indexPath.row].eventName
        cell.eventAddress.text = self.eventsArray[indexPath.row].eventAddress.replacingOccurrences(of: "|", with: " ")
        cell.companyName.text = self.eventsArray[indexPath.row].companyName
        // Create a reference to the file you want to download
        let eventImageRef = storageRef.child("images/\(self.eventsArray[indexPath.row].documentID)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        eventImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                cell.eventImage.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    func loadEvents() {
        self.eventsArray.removeAll()
        
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //populate array here
                    let eventData = Event(documentID: document.documentID, companyName: document.data()["companyName"] as! String, eventName: document.data()["eventName"] as! String, eventDescription: document.data()["eventDescription"] as! String, eventAddress: document.data()["eventAddress"] as! String, eventTime: document.data()["eventTime"] as! String, downloadURL: document.data()["downloadURL"] as! String)
                    self.eventsArray.append(eventData)
                    
//                    print("events data \(document.documentID) => \(document.data())")
                }
                DispatchQueue.main.async {
                    //Load data here
                    self.collectionViewOutlet.reloadData()
                }
            }
        }
    }
}

struct Event {
    var documentID: String
    var companyName: String
    var eventName: String
    var eventDescription: String
    var eventAddress: String
    var eventTime: String
    var downloadURL: String
}
