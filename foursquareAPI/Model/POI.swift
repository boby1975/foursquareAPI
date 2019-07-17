//
//  POI.swift
//  foursquareAPI
//
//  Created by iMAC on 7/15/19.
//  Copyright © 2019 OKO. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class POI: NSObject, MKAnnotation {
    let index: Int
    let venueId: String
    let venueName: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: Double
    let first: Bool
    let colorIndex: Int
    
    init(index: Int, venueId: String, venueName: String, coordinate: CLLocationCoordinate2D, address: String, distance: Double ){
        self.index = index
        self.venueId = venueId
        self.venueName = venueName
        self.coordinate = coordinate
        self.address = address
        self.distance = distance
        if index==0 {
            self.colorIndex = -1
            self.first = true
        }else{
            self.colorIndex = index % 9
            self.first = false
        }
    }
    
    //for map annotations
    var title: String? {
        return venueName
    }
    var subtitle: String? {
        return address
    }
 
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: address]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = venueName
        return mapItem
    }
    // markerTintColor for index colour
    var markerTintColor: UIColor  {
        switch colorIndex {
        case 0:
            return .green
        case 1:
            return .cyan
        case 2:
            return .blue
        case 3:
            return .purple
        case 4:
            return .brown
        case 5:
            return .magenta
        case 6:
            return .orange
        case 7:
            return .gray
        case 8:
            return .black
            
        default:
            return .red
        }
    }
    
}
