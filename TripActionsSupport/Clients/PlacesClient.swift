//
//  PlacesClient.swift
//  TripActionsSupport
//
//  Created by Eden on 1/30/18.
//  Copyright © 2018 Eden. All rights reserved.
//

//    prefill location with data from last-viewed-client. have search button disabled until location field filled out
//    don't worry about sorting results
//    will need to sort by price and rating on the client side
//    params: ["query": "cheese", "opennow": true, "type": "cafe"]

import Foundation
import MapKit

class PlacesClient {

    static let sharedInstance: PlacesClient = PlacesClient()
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Get places from string of text
    // https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+Sydney&radius=5000&type=cafe&keyword=vegetarian&key=YOUR_API_KEY
    func getPlaces(location: String?, places: String?, params: [String: Any]?, success: @escaping ([Place]) -> (), failure: @escaping (String, Error) -> ()){
        
//        dataTask?.cancel() // Cancel previous task
        
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
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    failure("DataTask error: \(error.localizedDescription)", error)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
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
    
    
    // Parse data from dataTask
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
    
    
    // Get coordinates from a human-readable place string
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
    
    
    // Get place details from place object
    // https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key=YOUR_API_KEY
    func getDetailsForPlace(place: Place, success: @escaping (PlaceDetails) -> (), failure: @escaping (String, Error) -> ()){
        
//        dataTask?.cancel() // Cancel previous task
        
        let method = "details/json"

        var queryString = "\(Constants.queryFields.placeId)=\(place.placeId!)&"
        queryString.append("\(Constants.queryFields.apiKey)=\(Constants.placesAPIKey)")
        print(queryString)
        if var urlComponents = URLComponents(string: Constants.baseURL+method) {
            urlComponents.query = queryString
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    failure("DataTask error: \(error.localizedDescription)", error)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    do {
                        let dicFromJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        print(dicFromJSON)
                        let resultDic = dicFromJSON["result"] as! [String: Any]
                        let placeDetails = PlaceDetails(place: place, dic: resultDic)
                        DispatchQueue.main.async {
                            success(placeDetails)
                        }
                    } catch let error {
                        failure("Failed to parse JSON: \(error.localizedDescription)", error)
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    
    // Get photo from photoReference
    // https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=YOUR_API_KEY
    func getPhotoForReference(photoReference: String, maxWidth: Int, maxHeight: Int, success: @escaping (UIImage) -> (), failure: @escaping (String, Error?) -> ()){
        
//        dataTask?.cancel() // Cancel previous task // come back to this
        
        let method = "photo"
        
        var queryString = "\(Constants.queryFields.maxWidth)=\(maxWidth)&"
        queryString.append("\(Constants.queryFields.maxHeight)=\(maxHeight)&")
        queryString.append("\(Constants.queryFields.photoReference)=\(photoReference)&")
        queryString.append("\(Constants.queryFields.apiKey)=\(Constants.placesAPIKey)")
        
        if var urlComponents = URLComponents(string: Constants.baseURL+method) {
            urlComponents.query = queryString
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    failure("DataTask error: \(error.localizedDescription)", error)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            success(image)
                        }
                    } else {
                        failure("Failed to create image from data ", nil)
                    }
                }
            }
        }
        dataTask?.resume()
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

