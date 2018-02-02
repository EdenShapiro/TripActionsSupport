//
//  PlaceDetails.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation

class PlaceDetails: NSObject {
//    var addressComponents: [String: Any?]?
    var formattedPhoneNumber: String?
    var internationalPhoneNumber: String?
    var website: URL?
    var openHours: [String: Any]?
    var photos: [[String: Any]]?

    
    init(place: Place, dic: [String: Any?]) {
        formattedPhoneNumber = dic["formatted_phone_number"] as? String
        internationalPhoneNumber = dic["international_phone_number"] as? String
        if let urlString = dic["website"] as? String {//}, let url = URL(string: urlString) {
            website = URL(string: urlString) //url
        }
        openHours = dic["opening_hours"] as? [String: Any]
        photos = dic["photos"] as? [[String: Any]]
        
//        if let photosArray = dic["photos"] as? [[String: Any]], photosArray.count > 0 {
//            let photoDic = photosArray[0]
//            photoReference = photoDic["photo_reference"] as? String
//        }
    }
    
//    class func getPhotos(photosArray: [[String: Any]]){
//        for element in photosArray {
//            for (key, value) in element {
//                
//            }
//        }
//    }

        
        
        
//        "address_components"
//        "place_id" : "ChIJN1t_tDeuEmsRUsoyG83frY4",
//        "id" : "4f89212bf76dde31f092cfc14d7506555d85b5c7",
//        "formatted_address" : "5, 48 Pirrama Rd, Pyrmont NSW 2009, Australia",
        
        
//        "formatted_phone_number" : "(02) 9374 4000",
//        "international_phone_number" : "+61 2 9374 4000",
//        "website" : "https://www.google.com.au/about/careers/locations/sydney/"

    
}
