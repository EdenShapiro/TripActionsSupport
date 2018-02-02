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
//    var photos: [[String: Any]]?
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
//        coordinate = CLLocationCoordinate2D(latitude: !, longitude: !)
//        "geometry" : {
//            "location" : {
//                "lat" : -33.870775,
//                "lng" : 151.199025
//            }
//        },
        
        if let urlString = dic["icon"] as? String {
            iconURL = URL(string: urlString)
        }
        id = dic["id"] as? String
        name = dic["name"] as? String
        if let openingHours = dic["opening_hours"] as? [String: Bool] {
            openNow = openingHours["open_now"]!
        }
        if let photosArray = dic["photos"] as? [[String: Any]], photosArray.count > 0 {
            let photoDic = photosArray[0]
            photoReference = photoDic["photo_reference"] as? String
        }
        
        
        //        "photos" : [
        //        {
        //        "html_attributions" : [],
        //        "height" : 853,
        //        "width" : 1280,
        //        "photo_reference" : "CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0"
        //        }

        
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
