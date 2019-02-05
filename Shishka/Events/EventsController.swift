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
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewOutlet.delegate = self
        self.collectionViewOutlet.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionViewOutlet.refreshControl = refreshControl
        } else {
            collectionViewOutlet.addSubview(refreshControl)
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()

        self.loadEvents()
    }
    
    @objc func refreshData(_ sender: Any) {
        self.loadEvents()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! EventCollectionViewCell
        cell.eventName.text = self.eventsArray[indexPath.row].eventName
        cell.eventAddress.text = self.eventsArray[indexPath.row].eventAddress?.replacingOccurrences(of: "|", with: " ")
        cell.companyName.text = self.eventsArray[indexPath.row].companyName
        cell.eventDescription = self.eventsArray[indexPath.row].eventDescription ?? "Blank"
        cell.eventTime = self.eventsArray[indexPath.row].eventTime ?? "Blank"
        cell.downloadURL = self.eventsArray[indexPath.row].downloadURL ?? "blank"
        cell.documentID = self.eventsArray[indexPath.row].documentID
        
        // Create a reference to the file you want to download
        let eventImageRef = storageRef.child("images/\(self.eventsArray[indexPath.row].documentID)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        eventImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                cell.eventImage.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    func loadEvents(){
        var tempEvents : [Event] = []
        
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    //populate array here
                    let eventData = Event(documentID: document.documentID,
                                          companyName: (document.data()["companyName"] as? String) ,
                                          eventName: document.data()["eventName"] as? String,
                                          eventDescription: document.data()["eventDescription"] as? String,
                                          eventAddress: (document.data()["eventAddress"] as? String),
                                          eventTime: document.data()["eventTime"] as? String,
                                          downloadURL: document.data()["downloadURL"] as? String)
                    tempEvents.append(eventData)
                }
                DispatchQueue.main.async {
//                  Load data here
                    self.eventsArray = tempEvents
                    self.collectionViewOutlet.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? EventCollectionViewCell,
            let indexPath = self.collectionViewOutlet.indexPath(for: cell) {
            
            let vc = segue.destination as! SingleEventCellViewController
            vc.companyName = cell.companyName.text ?? " "
            vc.eventDescription = cell.eventDescription
            vc.eventName = cell.eventName.text ?? " "
            vc.eventTime = cell.eventTime
            vc.eventAddress = cell.eventAddress.text ?? " "
            vc.downloadURL = cell.downloadURL
            vc.documentID = cell.documentID
        }
    }
}

struct Event {
    var documentID: String
    var companyName: String?
    var eventName: String?
    var eventDescription: String?
    var eventAddress: String?
    var eventTime: String?
    var downloadURL: String?
}
