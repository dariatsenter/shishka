//
//  BarterCollectionViewCell.swift
//  Shishka
//
//  Created by Daria Tsenter on 11/9/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit

class BarterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var productAddress: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    var productDescription: String = ""
    var downloadURL: String = ""
    var documentID: String = ""
    var productConditions: String = ""
    var isDelivery: Bool = false
}
