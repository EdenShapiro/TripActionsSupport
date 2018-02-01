//
//  PlacesClient.swift
//  TripActionsSupport
//
//  Created by Eden on 1/30/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation
import MapKit

class PlacesClient {
//    https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+Sydney&key=YOUR_API_KEY
//    https://maps.googleapis.com/maps/api/place/textsearch/json?query=123+main+street&location=42.3675294,-71.186966&radius=10000&key=YOUR_API_KEY
//    https://maps.googleapis.com/maps/api/place/textsearch/json?location=48.859294,2.347589&radius=5000&type=cafe&keyword=vegetarian&key=YOUR_API_KEY
    
//    static let sharedInstance: PlacesClient = PlacesClient(baseURL: URL(string: baseURL)!, placesKey: placesAPIKey)!
    static let sharedInstance: PlacesClient = PlacesClient()

    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    

    
//    prefill location with data from last-viewed-client. have search button disabled until location field filled out
//    don't worry about sorting results
//    will need to sort by price and rating on the client side
//    params: ["query": "cheese", "opennow": true, "type": "cafe"]
    
    func getPlaces(location: String?, places: String?, params: [String: Any]?, success: @escaping ([Place]) -> (), failure: @escaping (String, Error) -> ()){
        
        dataTask?.cancel() // Cancel previous task
        
        let method = "textsearch/json"
        let location = location != nil ? location! : "united states"
        let places = places != nil ? places! : "places"
        let textString = "\(places)+in+\(location)"
        let arr = textString.components(separatedBy: " ") // Just in case user entered whitespace
        
        var queryString = "\(Constants.queryFields.textQuery)=\(arr.joined(separator: "+"))&"
        if let params = params {
            for (key, value) in params {
                queryString.append("\(key)=\(value)&")
            }
        }
        queryString.append("\(Constants.queryFields.apiKey)=\(Constants.placesAPIKey)")
        if var urlComponents = URLComponents(string: Constants.baseURL+method) {
            urlComponents.query = queryString
//            print(urlComponents.url)
            guard let url = urlComponents.url else { return }
            
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    failure("DataTask error: \(error.localizedDescription)", error)
                } else if let data = data,
                    let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        self.parseData(data: data, success: { (places) in
                            DispatchQueue.main.async {
                                success(places)
                            }
                        }, failure: {(errorString, error) in
                            failure(errorString, error)
                        })
                    }
                }
            }
            dataTask?.resume()
    }
    
    func parseData(data: Data, success: @escaping ([Place]) -> (), failure: @escaping (String, Error) -> ()){
            do {
                let dicFromJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let resultsArray = dicFromJSON["results"] as! [[String: Any?]]
                let places = Place.placesFromArray(resultsArray: resultsArray)
                success(places)
            } catch let error {
                failure("Failed to parse JSON: \(error.localizedDescription)", error)
            }
        
    }
    
    func getCoordinatesFromString(locationString: String, success: @escaping (CLLocation) -> (), failure: @escaping  (String, Error?) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            if let placemark = placemarks?[0] {
                success(placemark.location!)
            } else {
                failure("No placemarks found", nil)
            }
            if let error = error {
                failure("Failure to find placemarks with locationString: \(error.localizedDescription)", error)
            }
        }
    }
    
}
        
        
        //        var params: [String: Any]?
//        get("textsearch/json?query=", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
    
//            let dicts = response as! [[String: Any?]]
//            let tweets = Tweet.tweetsWithArray(dicts: dicts)
//            success(tweets)
//
//        }, failure: { (task: URLSessionDataTask?, error: Error) in
//            failure(error)
//        })
//
//    }
//}
//
//https://maps.googleapis.com/maps/api/place/nearbysearch/json
//?location=-33.8670522,151.1957362
//&radius=500
//&types=food
//&name=harbour
//&key=

