//
//  Constants.swift
//  TripActionsSupport
//
//  Created by Eden on 1/30/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation

struct Constants {
    
    static let placesAPIKey = "AIzaSyB8vzfg24nzoyxchtMaCnje0ZFljFR5FdA"
    static let baseURL = "https://maps.googleapis.com/maps/api/place/"
    
    struct queryFields {
        static let textQuery = "query"
        static let location = "location"
        static let radius = "radius"
        static let minimumPrice = "minprice"
        static let maximumPrice = "maxprice"
        static let openNow = "opennow"
        static let pageToken = "pagetoken"
        static let type = "type"
        static let apiKey = "key"
        static let placeId = "placeid"
        static let maxWidth = "maxwidth"
        static let maxHeight = "maxheight"
        static let photoReference = "photoreference"


    }
    
}
