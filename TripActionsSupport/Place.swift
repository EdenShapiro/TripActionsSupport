//
//  Place.swift
//  TripActionsSupport
//
//  Created by Eden on 1/30/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation

class Place: NSObject {
    var location: [String: Float]?
    var iconURL: URL?
    var id: String?
    var name: String?
    var openNow: Bool = false
    var photos: [String: Any?]?
    var placeId: String?
    var types: [String]?
    var priceLevel: Int?
    var rating: Float?
    var formattedAddress: String?
    
    init(dic: [String: Any?]){
//        maybe if-let some of these to make sure there are dictionary results for them
        
        location = dic["location"] as? [String: Float]
        if let urlString = dic["icon"] as? String {
            iconURL = URL(string: urlString)
        }
        id = dic["id"] as? String
        name = dic["name"] as? String
        if let openingHours = dic["opening_hours"] as? [String: Bool] {
            openNow = openingHours["open_now"]!
        }
        photos =  dic["photos"] as? [String: Any?]
        placeId = dic["place_id"] as? String
        types = dic["types"] as? [String]
        priceLevel = dic["price_level"] as? Int
        rating = dic["rating"] as? Float
        formattedAddress = dic["formatted_address"] as? String
        
    }
    
    class func placesFromArray(resultsArray: [[String: Any?]]) -> [Place] {
        var places = [Place]()
        for dic in resultsArray {
            let place = Place(dic: dic)
            places.append(place)
        }
        return places
    }
    
    
}
