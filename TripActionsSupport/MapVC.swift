//
//  MapVC.swift
//  TripActionsSupport
//
//  Created by Eden on 1/31/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    var searchBarsContainerView: SearchBarsView?
    let placeClientInstance = PlacesClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map to initial view of United States
        let startingLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        let startingRegionRadius: CLLocationDistance = 1900000
        centerMapOnLocation(location: startingLocation, radius: startingRegionRadius)
        
        setUpSearchBarsContainerView()
        setUpSearchBars()
    }
    
    
    func setUpSearchBarsContainerView(){
        let rect = setContainerFrame(newScreenWidth: nil)
        searchBarsContainerView = SearchBarsView(frame: rect)
        searchBarsContainerView!.setRadiusWithShadow()
        self.view.addSubview(searchBarsContainerView!)
    }
    
    
    func setContainerFrame(newScreenWidth: CGFloat?) -> CGRect {
        var screenWidth: CGFloat
        if let newScreenWidth = newScreenWidth { // Device is about to be rotated
            screenWidth = newScreenWidth
        } else { // Just normal setup
            screenWidth = view.frame.width
        }
        let containerViewWidth:CGFloat = screenWidth - (screenWidth/10)
        let containerViewX: CGFloat = (screenWidth - containerViewWidth)/2
        let containerViewHeight:CGFloat = 113 //placesSearchBar.frame.height*2 + 1
        let containerViewY: CGFloat = view.frame.origin.y + 20
        
        let rect = CGRect(x: containerViewX, y: containerViewY, width: containerViewWidth, height: containerViewHeight)
        
        return rect
    }
    
    
    
    func setUpSearchBars(){
        searchBarsContainerView!.placesSearchBar.delegate = self
        searchBarsContainerView!.locationSearchBar.delegate = self
        searchBarsContainerView!.placesSearchBar.placeholder = "e.g. sheraton"
        searchBarsContainerView!.locationSearchBar.placeholder = "e.g. miami"
    }

//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBarsContainerView?.locationSearchBar.text?.replacingOccurrences(of: " ", with: "") == "" {
//
//        }
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let placesString = searchBarsContainerView!.placesSearchBar.text
        let locationString = searchBarsContainerView!.locationSearchBar.text
        placeClientInstance.getPlaces(location: locationString, places: placesString, params: nil, success: { (places) in
            for p in places {
                print(p.name)
            }
        }) { (errorString, error) in
            print(errorString)
        }
        
        placeClientInstance.getCoordinatesFromString(locationString: locationString!, success: { (location) in
            self.centerMapOnLocation(location: location, radius: nil)
        }) { (errorString, error) in
            print(errorString)
        }
        
    }
    
    
    func centerMapOnLocation(location: CLLocation, radius: Double?) {
        let regionRad = radius != nil ? radius! : regionRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRad, regionRad)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        searchBarsContainerView?.frame = setContainerFrame(newScreenWidth: size.width)
    }
    

}

extension UIView {
    
    func setRadiusWithShadow(_ radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
}

