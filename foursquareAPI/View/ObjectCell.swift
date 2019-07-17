//
//  ObjectCell.swift
//  foursquareAPI
//
//  Created by iMAC on 7/16/19.
//  Copyright © 2019 OKO. All rights reserved.
//

import UIKit

class ObjectCell: UICollectionViewCell {
   
    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var objectDistance: UILabel!
    @IBOutlet weak var objectAddress: UILabel!
    @IBOutlet weak var colorView: UIView!
   
    private var objectItem: POI!
  
    func configure(objectItem: POI){
        self.objectItem = objectItem
        objectName.text = self.objectItem.venueName
        objectAddress.text = self.objectItem.address
        let distance = "\(NSLocalizedString("Distance", comment: ""))  \(self.objectItem.distance) \(NSLocalizedString("meters", comment: ""))"
        objectDistance.text = distance
    }
    

}
