//
//  MapVC.swift
//  TripActionsSupport
//
//  Created by Eden on 1/31/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    var placeSuggestionResultsSC: UISearchController?
    var locationSuggestionResultsSC: UISearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map to initial view of United States
        let startingLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        let startingRegionRadius: CLLocationDistance = 1900000
        centerMapOnLocation(location: startingLocation, radius: startingRegionRadius)
        
        setUpSearchBars()
        
        setUpSearchbarLayouts(specialWidth: nil)
        
        let placeClientInstance = PlacesClient.sharedInstance
        placeClientInstance.getPlaces(location: "new york", places: "hotels", params: nil, success: { (places) in
            for p in places {
                print(p.name)
            }
        }) { (errorString, error) in
            print(errorString)
        }
    }
    
    
    
    func setUpSearchBars(){
        
        // Set up search controller and results table
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let placeSuggestionsTableVC = storyboard.instantiateViewController(withIdentifier: "TextSuggestionsTableVC") as! TextSuggestionsTableVC
        let locationSuggestionsTableVC = storyboard.instantiateViewController(withIdentifier: "TextSuggestionsTableVC") as! TextSuggestionsTableVC
        placeSuggestionResultsSC = UISearchController(searchResultsController: placeSuggestionsTableVC)
        placeSuggestionResultsSC!.searchResultsUpdater = placeSuggestionsTableVC
        placeSuggestionResultsSC!.hidesNavigationBarDuringPresentation = false
        locationSuggestionResultsSC = UISearchController(searchResultsController: locationSuggestionsTableVC)
        locationSuggestionResultsSC!.searchResultsUpdater = locationSuggestionsTableVC
//        definesPresentationContext = true
        locationSuggestionResultsSC!.hidesNavigationBarDuringPresentation = false
        
        
        //Set up search bars
        let placesSearchBar = placeSuggestionResultsSC!.searchBar
        placesSearchBar.backgroundColor = .white
        placesSearchBar.placeholder = "e.g. sheraton"
        
        let locationSearchBar = locationSuggestionResultsSC!.searchBar
        locationSearchBar.backgroundColor = .white
        locationSearchBar.placeholder = "e.g. miami"
    }
    
    func setUpSearchbarLayouts(specialWidth: CGFloat?){
        let placesSearchBar = placeSuggestionResultsSC!.searchBar
        let locationSearchBar = locationSuggestionResultsSC!.searchBar

        // Set up container view
//        let navBar = CustomNavigationBar(hiddenStatusBar: false)
//        self.navigationController!.set
//        UINavigationController(navigationBarClass: CustomNavigationBar, toolbarClass: nil)
        
//        let navBar = navigationController!.navigationBar
        
//        let navBarOriginalHeight = navBar.frame.height
//        let navBarNewHeight = navBarOriginalHeight + 56 //accounts for added height of additional searchbar
//        navBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
        
        
        
        let containerViewWidth:CGFloat = specialWidth != nil ? specialWidth! : view.frame.width - 24  //maybe change this
        let containerViewHeight:CGFloat = placesSearchBar.frame.height*2 + 1
        let containerViewX: CGFloat = view.frame.origin.x + 8
        let containerViewY: CGFloat = view.frame.origin.y + 20
        let searchBarsContainerView = UIView(frame: CGRect(x: containerViewX, y: containerViewY, width: containerViewWidth, height: containerViewHeight))
//        searchBarsContainerView.isUserInteractionEnabled = true
        
        
        
        
        //Set up searchbars
        placesSearchBar.frame.size = CGSize(width: searchBarsContainerView.frame.width, height: 50)
        placesSearchBar.sizeToFit()
        
        let hairLineView = UIView()
        hairLineView.frame.size = CGSize(width: placesSearchBar.frame.width - 4, height: 0.2)
        hairLineView.frame.origin.y = placesSearchBar.frame.origin.y + placesSearchBar.frame.height
        hairLineView.backgroundColor = .lightGray
        
        locationSearchBar.frame.size = CGSize(width: searchBarsContainerView.frame.width, height: 50)
        locationSearchBar.frame.origin.y = placesSearchBar.frame.origin.y + hairLineView.frame.height + placesSearchBar.frame.height
        locationSearchBar.sizeToFit()
        
        
        // Add searchbars to container
        searchBarsContainerView.addSubview(placesSearchBar)
        searchBarsContainerView.addSubview(hairLineView)
        searchBarsContainerView.addSubview(locationSearchBar)
//        placesSearchBar
//        searchBarsContainerView.bringSubview(toFront: locationSearchBar)
        searchBarsContainerView.setRadiusWithShadow()
//        self.navigationItem.titleView = searchBarsContainerView
        self.view.addSubview(searchBarsContainerView)
//        self.navigationItem.vi
//        self.navigationController!.navigationBar.sizeToFit()
        
    }
    
    func centerMapOnLocation(location: CLLocation, radius: Double?) {
        let regionRad = radius != nil ? radius! : regionRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRad, regionRad)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if (size.width > size.height){
            // Position elements for Landscape
            setUpSearchbarLayouts(specialWidth: size.width - 60)

        } else {
            // Position elements for Portrait
            setUpSearchbarLayouts(specialWidth: size.width - 24)
        }
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
//extension UINavigationBar {
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        for subview in self.subviews {
//            var stringFromClass = NSStringFromClass(subview.classForCoder)
//            print("--------- \(stringFromClass)")
//            if stringFromClass.contains("BarBackground") {
//                subview.frame = self.bounds
//            } else if stringFromClass.contains("UINavigationBarContentView") {
//                subview.frame = self.bounds
//            }
//        }
//    }
//}


//        searchBarsContainerView.sizeToFit()

//        placesSearchBar.frame = CGRect(x: searchBarsContainerView.frame.origin.x, y: searchBarsContainerView.frame.origin.y, width: placesSearchBar.frame.width - 8, height: placesSearchBar.frame.height)
//
//        placesSearchBar.sizeThatFits(searchBarsContainerView.frame.size)
//        locationSearchBar.sizeThatFits(searchBarsContainerView.frame.size)
//
//        locationSearchBar.frame = CGRect(x: searchBarsContainerView.frame.origin.x, y: searchBarsContainerView.frame.origin.y + placesSearchBar.frame.height + 1, width: locationSearchBar.frame.width - 8 , height: locationSearchBar.frame.height)
//
//        let hairLineView = UIView(frame: CGRect(x: searchBarsContainerView.frame.origin.x, y: searchBarsContainerView.frame.origin.y + placesSearchBar.frame.height, width: searchBarsContainerView.frame.width - 8, height: 0.5))


//class CustomNavigationBar: UINavigationBar {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
////    private let hiddenStatusBar: Bool
////
////    // MARK: Init
////    init(hiddenStatusBar: Bool = false) {
////        self.hiddenStatusBar = hiddenStatusBar
////        super.init(frame: .zero)
////    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//
//    // MARK: Overrides
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if #available(iOS 11.0, *) {
//            let hiddenStatusBar = false
//            for subview in self.subviews {
//                let stringFromClass = NSStringFromClass(subview.classForCoder)
//                if stringFromClass.contains("BarBackground") {
//                    subview.frame = self.bounds
//                } else if stringFromClass.contains("BarContentView") {
////                    let statusBarHeight = hiddenStatusBar ? 0 : UIApplication.shared.statusBarFrame.height
////                    subview.frame.origin.y = statusBarHeight
//                    subview.frame.size.height = 120//self.bounds.height - statusBarHeight
//                } else if stringFromClass.contains("UINavigationBarContentView") {
////                    subview.frame = self.bounds
//                    subview.frame.size.height = 120
//                }
//            }
//        }
//    }
//}
//
//extension UINavigationController {
//    override open func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let height = CGFloat(120)
//        navigationBar.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: height)
//        navigationBar.backgroundColor = .green
//    }
//}



