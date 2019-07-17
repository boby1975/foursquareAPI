//
//  ViewController.swift
//  foursquareAPI
//
//  Created by iMAC on 7/15/19.
//  Copyright © 2019 OKO. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var objectCollectionView: UICollectionView!
    @IBOutlet weak var objectCollectionViewConstraintHeight: NSLayoutConstraint!
    
    private var POIs: [POI] = [] //array of objects to display on the map and collectionView
    private let queryService = QueryService()
    private var regionRadius: CLLocationDistance!
    private var mapCenterLeftDone = false
    private var mapCenterRightDone = false
    
    // MARK: - Constants
    private enum Constants {
        static let iniFindLat = "40.7243"
        static let iniFindLon = "-74.0018"
        static let iniFindQuery = "shop" //coffee, shop
        static let iniLeftTopCorner = CLLocationCoordinate2D(latitude: 50.46, longitude: 30.52)
        static let iniRightBottomCorner = CLLocationCoordinate2D(latitude: 50.46, longitude: 30.52)
        static let iniRegionRadius: CLLocationDistance = 5000 //meters
        static let minRegionRadius: CLLocationDistance = 500 //meters
        static let reuseID = "objectCell"
        static let iniCellWidth = UIScreen.main.bounds.width
        static let iniCellHeight = UIScreen.main.bounds.height/4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("MapViewControllerDidLoad")
        
        regionRadius = Constants.iniRegionRadius

        //try query data with some filter
        getPOI(lat: Constants.iniFindLat, lon: Constants.iniFindLon, query: Constants.iniFindQuery)
        
        //initial map location
        let initialLocation = CLLocation(latitude: (Constants.iniLeftTopCorner.latitude + Constants.iniRightBottomCorner.latitude)/2, longitude: (Constants.iniLeftTopCorner.longitude + Constants.iniRightBottomCorner.longitude)/2)
        centerMapOnLocation(location: initialLocation, regionRadius: regionRadius)
        
        mapView.delegate = self
        mapView.register(POIMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        objectCollectionView.delegate = self
        objectCollectionView.dataSource = self
        objectCollectionView.showsHorizontalScrollIndicator = false
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action:#selector(self.swiped(_:)))
        swipeGesture.delegate = self
        objectCollectionView.addGestureRecognizer(swipeGesture)
        
        
        //let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwiped))
        //swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        //swipeRight.delegate = self
        //objectCollectionView.addGestureRecognizer(swipeRight)
        
        //let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwiped))
        //swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        //swipeLeft.delegate = self
        //objectCollectionView.addGestureRecognizer(swipeLeft)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("MapViewControllerWillAppear")
        
        objectCollectionViewConstraintHeight.constant = Constants.iniCellHeight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print ("MapViewControllerDidAppear")
        
        checkLocationAuthorizationStatus()
    }
    

    
    // MARK: CLLocationManager
    let locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    //MARK: Private
    fileprivate func getPOI(lat: String, lon: String, query: String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getPOIResult(lat: lat, lon: lon, query: query){  [weak self] results, errorMessage  in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let _ = self else {
                print ("MapViewController is nil")
                return
            }
            
            if let results = results {
                if results.count > 0 {
                    print ("result query POIs ok")
                } else {
                    print ("query POIs no records")
                }
                
                self?.updateData(data: results)
            }
            if !errorMessage.isEmpty { print("query POIs error: " + errorMessage) }
        }
    }
    
    fileprivate func updateData (data: [POI]) {
        POIs = data
        
        // set map location
        var wasPOI = false
        var leftTopCorner = Constants.iniLeftTopCorner
        var rightBottomCorner = Constants.iniRightBottomCorner
        
        
        if let firstPOI = POIs.first {
            leftTopCorner = firstPOI.coordinate
            rightBottomCorner = firstPOI.coordinate
            wasPOI = true
        }
        for curPOI in POIs {
            if leftTopCorner.latitude < curPOI.coordinate.latitude {
                leftTopCorner.latitude = curPOI.coordinate.latitude
            }
            if leftTopCorner.longitude > curPOI.coordinate.longitude {
                leftTopCorner.longitude = curPOI.coordinate.longitude
            }
            if rightBottomCorner.latitude > curPOI.coordinate.latitude {
                rightBottomCorner.latitude = curPOI.coordinate.latitude
            }
            if rightBottomCorner.longitude < curPOI.coordinate.longitude {
                rightBottomCorner.longitude = curPOI.coordinate.longitude
            }
        }
        
        let mapCenterLocation = CLLocation(latitude: (leftTopCorner.latitude + rightBottomCorner.latitude)/2, longitude: (leftTopCorner.longitude + rightBottomCorner.longitude)/2)
        
        let leftTop = CLLocation (latitude: leftTopCorner.latitude, longitude: leftTopCorner.longitude)
        let rightBottom = CLLocation (latitude: rightBottomCorner.latitude, longitude: rightBottomCorner.longitude)
        regionRadius = Constants.iniRegionRadius
        if wasPOI {
            regionRadius = leftTop.distance(from: rightBottom) * 1.3
        }
        if regionRadius < Constants.minRegionRadius {
            regionRadius = Constants.minRegionRadius
        }
        print ("regionRadius=\(regionRadius ?? Constants.iniRegionRadius)")
        centerMapOnLocation(location: mapCenterLocation, regionRadius: regionRadius)
        mapView.addAnnotations(POIs)
        
        objectCollectionView.reloadData()
        //objectCollectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    fileprivate func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance ) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}


// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        
        guard let location = view.annotation as? POI else {
            print("Error: cannot create POI from annotation")
            return
        }
        
        print ("Route to \"\(location.title!)\"")
        
        if control == view.rightCalloutAccessoryView
        {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking] //MKLaunchOptionsDirectionsModeDriving
            location.mapItem().openInMaps(launchOptions: launchOptions)
            
        }
        
        if control == view.leftCalloutAccessoryView
        {

        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title \"\(annotationTitle!)\"")
        }

        guard let location = view.annotation as? POI else {
            print("Error: cannot create POI from annotation")
            return
        }
        print("index=\(location.index)")
        
        //center specific cell of collectionview
        objectCollectionView.scrollToItem(at: IndexPath(item: location.index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {

        if let annotationTitle = view.annotation?.title
        {
            print("User deselected annotation with title \"\(annotationTitle!)\"")
        }
        //do something if need

    }
    
}

// MARK: Collection view delegate and data source methods
extension MapViewController :  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return POIs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseID, for: indexPath) as! ObjectCell
        cell.configure(objectItem: POIs[indexPath.row])

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = indexPath.row
        print("selected cell: \(selectedCell)")
        
        //center map to cell object coordinate
        let mapCenterLocation = CLLocation(latitude: POIs[selectedCell].coordinate.latitude, longitude: POIs[selectedCell].coordinate.longitude)
        centerMapOnLocation(location: mapCenterLocation , regionRadius: regionRadius)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        //let width  = view.frame.width
        return CGSize(width: Constants.iniCellWidth, height: Constants.iniCellHeight) 
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScrolling(scrollView)
        }
    }
    
    fileprivate func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        print ("scrollViewDidEndScrolling")
        
        //check if cell cover screen center
        let centerCriteria = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY*0.9)
        let collectionViewCenterCriteria = view.convert(centerCriteria, to: objectCollectionView)
        
        if let indexPath = objectCollectionView.indexPathForItem(at: collectionViewCenterCriteria) {
                //let collectionViewCell = objectCollectionView.cellForItem(at: indexPath)
                let centerCell = indexPath.row
                print ("Cell with index=\(centerCell) cover center")
            
                //center specific cell of collectionview
                objectCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                //center map to cell object coordinate
                let mapCenterLocation = CLLocation(latitude: POIs[centerCell].coordinate.latitude, longitude: POIs[centerCell].coordinate.longitude)
                centerMapOnLocation(location: mapCenterLocation , regionRadius: regionRadius)
        }
    }
    
}


// MARK: UIGestureRecognizerDelegate
extension MapViewController:  UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @objc func swiped(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch(gestureRecognizer.state) {
        case UIGestureRecognizerState.began:
            //print("UIGestureRecognizerState.began")
            mapCenterLeftDone = false
            mapCenterRightDone = false
        case UIGestureRecognizerState.changed:
            let translation: CGPoint = gestureRecognizer.translation(in: objectCollectionView)
            let displacement: CGPoint = CGPoint.init(x: translation.x, y: translation.y)
            

            if displacement.x > 0 && displacement.x>UIScreen.main.bounds.maxX*0.3 && !mapCenterRightDone {
                print ("swiping to the right")
                mapCenterRightDone = true
                mapCenterLeftDone = false
                
                let criteria = CGPoint(x: UIScreen.main.bounds.maxX*0.2, y: UIScreen.main.bounds.maxY*0.9)
                let collectionViewCenterCriteria = view.convert(criteria, to: objectCollectionView)
                if let indexPath = objectCollectionView.indexPathForItem(at: collectionViewCenterCriteria) {
                    let centerCell = indexPath.row
                    print ("Cell with index=\(centerCell) appeared on the left")
                    
                    //center map to cell object coordinate
                    let mapCenterLocation = CLLocation(latitude: POIs[centerCell].coordinate.latitude, longitude: POIs[centerCell].coordinate.longitude)
                    centerMapOnLocation(location: mapCenterLocation , regionRadius: regionRadius)
                }
                
            }
            
            if displacement.x < 0 && abs(displacement.x) > UIScreen.main.bounds.maxX*0.3 && !mapCenterLeftDone {
                print ("swiping to the left")
                mapCenterRightDone = false
                mapCenterLeftDone = true
                
                let criteria = CGPoint(x: UIScreen.main.bounds.maxX*0.8, y: UIScreen.main.bounds.maxY*0.9)
                let collectionViewCenterCriteria = view.convert(criteria, to: objectCollectionView)
                if let indexPath = objectCollectionView.indexPathForItem(at: collectionViewCenterCriteria) {
                    let centerCell = indexPath.row
                    print ("Cell with index=\(centerCell) appeared on the right")
                    
                    //center map to cell object coordinate
                    let mapCenterLocation = CLLocation(latitude: POIs[centerCell].coordinate.latitude, longitude: POIs[centerCell].coordinate.longitude)
                    centerMapOnLocation(location: mapCenterLocation , regionRadius: regionRadius)
                }
            }
            
            if displacement.y > 0 && displacement.y > UIScreen.main.bounds.maxY*0.1 && abs(displacement.x) < UIScreen.main.bounds.maxX*0.1 {
                print ("swiping to the down")
                
            }
            
            if displacement.y < 0 && abs(displacement.y) > UIScreen.main.bounds.maxY*0.1 && abs(displacement.x) < UIScreen.main.bounds.maxX*0.1 {
                print ("swiping to the up")
                
                let criteria = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY*0.9)
                let collectionViewCenterCriteria = view.convert(criteria, to: objectCollectionView)
                if let indexPath = objectCollectionView.indexPathForItem(at: collectionViewCenterCriteria) {
                    let collectionViewCell = objectCollectionView.cellForItem(at: indexPath)

                
                }
            }
        case UIGestureRecognizerState.ended:
            //print("UIGestureRecognizerState.ended")

            break
            
        default:
            break
        }
    }
    
    @objc func rightSwiped()
    {
        print("right swiped ")
        
    }
    
    @objc func leftSwiped()
    {
        print("left swiped ")
        
    }
    
    
}
