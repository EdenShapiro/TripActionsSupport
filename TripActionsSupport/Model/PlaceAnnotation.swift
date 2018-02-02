//
//  PlaceAnnotation.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject,  MKAnnotation {
    var place: Place!
    let title: String?
    let locationName: String
    let discipline: String?
    var coordinate: CLLocationCoordinate2D

    init(place: Place) {
        self.place = place
        self.coordinate = place.location!.coordinate
        self.title = place.name!
        self.locationName = place.formattedAddress!
        self.discipline = place.types?[0]
    }
    
}
