//
//  BarterViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 11/9/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "barterCellId"

class BarterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    weak var collectionViewDelegate: UICollectionViewDelegate?
    //store barter from firestore here
    private var barterArray: [Barter] = []
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
        // [END setup]
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        self.loadBarters()
    }
    
    @objc func refreshData(_ sender: Any) {
        self.loadBarters()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.barterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! BarterCollectionViewCell
        cell.productName.text = self.barterArray[indexPath.row].productName
        cell.productAddress.text = self.barterArray[indexPath.row].productAddress?.replacingOccurrences(of: "|", with: " ")
        cell.companyName.text = self.barterArray[indexPath.row].companyName
        cell.productDescription = self.barterArray[indexPath.row].productDescription ?? "Blank"
        cell.productConditions = self.barterArray[indexPath.row].productConditions ?? "Blank"
        cell.isDelivery = self.barterArray[indexPath.row].isDelivery ?? false
        cell.downloadURL = self.barterArray[indexPath.row].downloadURL ?? "blank"
        cell.documentID = self.barterArray[indexPath.row].documentID
        
        // Create a reference to the file you want to download
        let productImageRef = storageRef.child("images/\(self.barterArray[indexPath.row].documentID)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        productImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                cell.productImage.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    func loadBarters(){
        var tempBarters : [Barter] = []
        
        db.collection("barter").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    print("in for document in querySnapshot!.documents")
                    //populate array here
                    let barterData = Barter(documentID: document.documentID,
                                          companyName: (document.data()["companyName"] as? String) ,
                                          productName: document.data()["productName"] as? String,
                                          productDescription: document.data()["productDescription"] as? String,
                                          productConditions: document.data()["productConditions"] as? String, productAddress: (document.data()["productAddress"] as? String),
                                          downloadURL: document.data()["downloadURL"] as? String, isDelivery: document.data()["isDelivery"] as? Bool)
                    tempBarters.append(barterData)
                    print("appended")
                }
                DispatchQueue.main.async {
                    //                  Load data here
                    self.barterArray = tempBarters
                    self.collectionViewOutlet.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? BarterCollectionViewCell,
            let indexPath = self.collectionViewOutlet.indexPath(for: cell) {
            
            let vc = segue.destination as! SingleBarterViewController
            vc.companyName = cell.companyName.text ?? " "
            vc.productDescription = cell.productDescription
            vc.productName = cell.productName.text ?? " "
            vc.isDelivery = cell.isDelivery
            vc.productAddress = cell.productAddress.text ?? " "
            vc.downloadURL = cell.downloadURL
            vc.documentID = cell.documentID
            vc.productConditions = cell.productConditions
        }
    }
}

struct Barter {
    var documentID: String
    var companyName: String?
    var productName: String?
    var productDescription: String?
    var productConditions: String?
    var productAddress: String?
    var downloadURL: String?
    var isDelivery: Bool?
}
