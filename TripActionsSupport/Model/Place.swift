//
//  Place.swift
//  TripActionsSupport
//
//  Created by Eden on 1/30/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation
import MapKit

class Place: NSObject {
    var location: CLLocation?
    var iconURL: URL?
    var id: String?
    var name: String?
    var openNow: Bool = false
    var photoReference: String?
    var placeId: String?
    var types: [String]?
    var priceLevel: Int?
    var rating: Float?
    var formattedAddress: String?

    
    init(dic: [String: Any?]){
        if let geometry = dic["geometry"] as? [String: Any], let loc = geometry["location"] as? [String: Double]{
            location = CLLocation(latitude: loc["lat"]!, longitude: loc["lng"]!)
        }
        
        if let urlString = dic["icon"] as? String {
            iconURL = URL(string: urlString)
        }
        id = dic["id"] as? String
        name = dic["name"] as? String
        if let openingHours = dic["opening_hours"] as? [String: Any] {
            openNow = openingHours["open_now"] as! Bool
        }
        if let photosArray = dic["photos"] as? [[String: Any]], photosArray.count > 0 {
            let photoDic = photosArray[0]
            photoReference = photoDic["photo_reference"] as? String
        }
        
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
