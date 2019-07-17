//
//  POIMarkerView.swift
//  foursquareAPI
//
//  Created by iMAC on 7/16/19.
//  Copyright © 2019 OKO. All rights reserved.
//

import Foundation
import MapKit

class POIMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let poi = newValue as? POI else { return }
            canShowCallout = true
            //calloutOffset = CGPoint(x: -5, y: 5)
            //rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton //for MAPs app
            
            
            
            
            // 2
            glyphText = nil
            markerTintColor = poi.markerTintColor
            if poi.first {
                glyphImage = UIImage(named: "Flag")
            } else {
                glyphText = String(poi.title!.first!)
            }
 
            //3
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0 //0, 1
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = poi.subtitle
            detailLabel.isHidden = false //true
            detailCalloutAccessoryView = detailLabel
            
            //4 left button for info popup window
            //leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    }
}
