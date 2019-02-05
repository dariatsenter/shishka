//
//  EventCellCollectionViewCell.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/4/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    var eventDescription: String = ""
    var eventTime: String = ""
    var downloadURL: String = ""
    var documentID: String = ""
}
