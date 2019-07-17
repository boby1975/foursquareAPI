//
//  QueryService.swift
//  foursquareAPI
//
//  Created by iMAC on 7/15/19.
//  Copyright © 2019 OKO. All rights reserved.
//

import Foundation
import MapKit

// Runs query data task and stores result in array
class QueryService {
    //https://developer.foursquare.com/docs/api
    private let apiClientId = "YOUR CLIENT ID"
    private let apiClinetSecret = "YOUR CLIENT SECRET"
    
    typealias JSONDictionary = [String: Any]
    typealias POIResult = ([POI]?, String) -> ()

    
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    private var POIs: [POI] = []
    private var errorMessage = ""
    
    
    func getPOIResult(lat: String, lon: String, query: String, completion: @escaping POIResult) {
        
        dataTask?.cancel()

        if var urlComponents = URLComponents(string: "https://api.foursquare.com/v2/venues/explore") {
            urlComponents.query = "client_id=\(apiClientId)&client_secret=\(apiClinetSecret)&v=20180323&limit=5&ll=\(lat),\(lon)&query=\(query)"
            
            guard let url = urlComponents.url else { return }
            
            print (url)
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                guard let _ = self else {
                    print ("QueryService is nil")
                    return
                }
                
                defer { self?.dataTask = nil }
                
                if let error = error {
                    self?.errorMessage += "POI DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self?.updatePOIResult(data)
                    
                    DispatchQueue.main.async {
                        completion(self?.POIs, self?.errorMessage ?? "")
                    }
                }
            }
            
            dataTask?.resume()
        }
    }
    
    fileprivate func updatePOIResult(_ data: Data) {
        var response: JSONDictionary?
        POIs.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
            
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        //print (response)

        guard let response_key = response!["response"] as? JSONDictionary else {
            errorMessage += "Response does not contain \"response\" key\n"
            return
        }
        //print (response_key)
        
        guard let groups_key = response_key["groups"] as? [Any] else {
            errorMessage += "Response does not contain \"groups\" key\n"
            return
        }
        //print (groups_key)
   
        guard let items_key = (groups_key[0] as! JSONDictionary)["items"] as? [Any] else {
            errorMessage += "Response does not contain \"items\" key\n"
            return
        }
        //print (items_key)
        
        
        var index = 0
        for poiDictionary in items_key {
            if let poiDictionary = poiDictionary as? JSONDictionary,
                let venue = poiDictionary["venue"] as? JSONDictionary,
                let venueId = venue["id"] as? String,
                let venueName = venue["name"] as? String,
                let location = venue["location"] as? JSONDictionary,
                let address = location["address"] as? String,
                let distance = location["distance"] as? Double,
                let lat = location["lat"] as? Double,
                let lng = location["lng"] as? Double {
                
                POIs.append(POI(index: index, venueId: venueId, venueName: venueName, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), address: address, distance: distance))
                index += 1
            } else {
                errorMessage += "Problem parsing poiDictionary\n"
            }
        }
        
        print("POI index=\(index)")
    }
    
    
}
