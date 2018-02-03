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
        
        mapView.delegate = self
        
        // Set up map to initial view of United States
        let startingLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        let startingRegionRadius: CLLocationDistance = 5000000
        centerMapOnLocation(location: startingLocation, radius: startingRegionRadius)
        
        setUpSearchBarsContainerView()
        setUpSearchBars()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardAndDrawer))
        view.addGestureRecognizer(tapGesture)
    
    }
    
    @objc func hideKeyboardAndDrawer(){
        hideDrawer()
        hideKeyboard()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
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
        mapView.removeAnnotations(mapView.annotations)
        let placesString = searchBarsContainerView!.placesSearchBar.text
        let locationString = searchBarsContainerView!.locationSearchBar.text
        placeClientInstance.getPlaces(location: locationString, places: placesString, params: nil, success: { (places) in
            var annotations = [PlaceAnnotation]()
            for p in places {
                let placeAnnotation = PlaceAnnotation(place: p)
                annotations.append(placeAnnotation)
//                self.mapView.addAnnotation(placeAnnotation)
                print(p.name!)
            }
            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.addAnnotations(annotations)
        }) { (errorString, error) in
            print(errorString)
        }
        hideKeyboard()
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

extension MapVC: MKMapViewDelegate {
    
//    TODO:
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var annotationView: MKAnnotationView!
//        if let ann = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation") as? MKAnnotationView {
//            annotationView = ann
//            annotationView.tintColor = UIColor.TripActionsColors.orange
//        } else {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
//            annotationView.tintColor = UIColor.TripActionsColors.orange
//            annotationView.image = #imageLiteral(resourceName: "Small orange pin")
//        }
//        return annotationView
//    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let placeAnnotation = view.annotation as! PlaceAnnotation
        setUpBottomDrawer(placeAnnotation: placeAnnotation)
        print(placeAnnotation.place.name)
//        view.image = #imageLiteral(resourceName: "Big pin")
    }
    
}




extension MapVC { //: DrawerDelegate {
    
    func setUpBottomDrawer(placeAnnotation: PlaceAnnotation){

        removeChildVC()

        let drawerVC = DrawerVC()
        
        // Create smallView
        let drawerSmallView = PlaceSmallDrawerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 169))
        drawerSmallView.place = placeAnnotation.place
        
        // Create bigView
        let drawerBigView = PlaceDetailsView(frame: self.view.frame)
        drawerBigView.place = placeAnnotation.place
        drawerBigView.delegate = drawerVC
        
        drawerVC.smallView = drawerSmallView
        drawerVC.bigView = drawerBigView
        // Adjust bottomDrawerVC frame and initial position (below the screen)
        drawerVC.view.frame.origin.y = self.view.frame.maxY
        
        // Add bottomDrawerVC as a child view
        addChildViewController(drawerVC)
        view.addSubview(drawerVC.view)
        UIApplication.shared.keyWindow?.insertSubview(drawerVC.view, aboveSubview: self.view)

    }
    
    
    func hideDrawer() {
        // slide down, remove child
        if let childVC = self.childViewControllers.last as? DrawerVC {
            UIView.animate(withDuration: 0.3, animations: {
                childVC.view.frame.origin.y = self.view.frame.maxY

            }, completion: { (finished: Bool) in
                self.removeChildVC()
            })
        }
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }

    func removeChildVC(){

        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()

            print("removing last childvc")
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

//extension MKPinAnnotationView {
//    class func pinColor() -> UIColor {
//        return UIColor.TripActionsColors.orange
//    }
//}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    struct TripActionsColors {
        static let orange = UIColor(netHex: 0xFF671B)
    }
}
