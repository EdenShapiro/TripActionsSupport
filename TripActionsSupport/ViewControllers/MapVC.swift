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
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var panGesture: UIPanGestureRecognizer!
    
    let regionRadius: CLLocationDistance = 1000
    var searchBarsContainerView: SearchBarsView?
    let placeClientInstance = PlacesClient.sharedInstance
    var isOpen = false
    fileprivate var partialDrawerHeight: CGFloat = 328.0
    fileprivate var partialDrawerTopY: CGFloat = UIScreen.main.bounds.height - 328.0
    fileprivate var partialDrawerConstraintConstant = UIScreen.main.bounds.height - 328.0
    fileprivate var tableViewContentOffsetTop: CGFloat = -20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up map to initial view of United States
        let startingLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        let startingRegionRadius: CLLocationDistance = 5000000
        centerMapOnLocation(location: startingLocation, radius: startingRegionRadius)
        
        setUpSearchBarsContainerView()
        setUpSearchBars()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardAndDrawer))
        view.addGestureRecognizer(tapGesture)
        
        setUpPanGestureRecognizer()
        
        tableViewTopConstraint.constant = partialDrawerConstraintConstant
        self.tableViewBottomConstraint.constant = -(UIScreen.main.bounds.height) //- self.partialDrawerHeight + 60)
        self.view.updateConstraintsIfNeeded()
        
        
        let locationString = "chicago"
        let placesString = "hotels"
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
        
        tableView.reloadData()
    
    }
    
    @objc func hideKeyboardAndDrawer(){
//        hideDrawer()
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
//        setUpBottomDrawer(placeAnnotation: placeAnnotation)
        print(placeAnnotation.place.name)
//        view.image = #imageLiteral(resourceName: "Big pin")
    }
    
}


extension MapVC: UIGestureRecognizerDelegate {
    
    func openDrawer(with verticalVelocity: CGFloat?){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.tableView.frame.origin.y = 0
//            self?.tableView.frame.maxY = UIScreen.main.bounds.height
            self?.tableViewTopConstraint.constant = 0
//            self?.tableViewBottomConstraint.isActive = true
            self?.tableViewBottomConstraint.constant = 0
//            if let vertVel = verticalVelocity, let contentSize = self?.tableView.contentSize.height {
//                let y = vertVel < contentSize ? vertVel : contentSize
//                let point = CGPoint(x: (self?.tableView.contentOffset.x)!, y: y)//vertVel/self.tableView.contentSize.height
//                self?.tableView.setContentOffset(point, animated: true)
//            }
            self?.view.layoutIfNeeded()
            self?.view.updateConstraintsIfNeeded()
            }, completion: { (finished: Bool) in
                self.isOpen = true
                self.tableView.isScrollEnabled = true
//                if let vertVel = verticalVelocity {
//                    let contentSize = self.tableView.contentSize.height
//                    let y = vertVel < contentSize ? vertVel : contentSize
//                    let point = CGPoint(x: self.tableView.contentOffset.x, y: y)//vertVel/self.tableView.contentSize.height
//                    self.tableView.setContentOffset(point, animated: true)
//                }
//                self.view.layoutIfNeeded()
//                self.view.updateConstraintsIfNeeded()
//                self.tableView.scrollToRow(at: <#T##IndexPath#>, at: .none, animated: true)
//                self.tableView.contentSize.height

        })
        
    }
    
    func closeDrawer(completion: (() -> Void)?){
        UIView.animate(withDuration: 0.3, animations: { [weak self] () in
            self?.tableView.frame.origin.y = (self?.view.frame.maxY)! - (self?.partialDrawerHeight)!
            self?.tableViewTopConstraint.constant = (self?.partialDrawerConstraintConstant)!
            self?.tableViewBottomConstraint.constant = -(UIScreen.main.bounds.height)//- (self?.partialDrawerHeight)!)
            self?.tableView.setContentOffset(CGPoint.zero, animated: true)

            self?.view.updateConstraintsIfNeeded()
            self?.view.layoutIfNeeded()
            
            }, completion: { (finished: Bool) in
                self.isOpen = false
                self.tableView.isScrollEnabled = false
        })
    }
    
    func hideDrawerCompletely(){
        
    }
    
    func setUpPanGestureRecognizer(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        if recognizer.state == .began {
            
        } else if recognizer.state == .changed {
            var currentDrawerHeight: CGFloat!
            let fullScreenHeight = UIScreen.main.bounds.height
            print("in handle pan")
            
            if isOpen {
                print("is open")
                print("tableView.contentOffset.y: \(tableView.contentOffset.y)")
                print("translation.y: \(translation.y)")
                
                
                if translation.y > 0 && tableView.contentOffset.y <= 0 {
//                    currentDrawerHeight = 20 + translation.y
                    currentDrawerHeight = translation.y //test
                    tableView.isScrollEnabled = false
                    tableView.frame.origin.y = currentDrawerHeight
                    
                } else {
                    tableView.isScrollEnabled = true
                    print("tableView.isScrollEnabled: \(tableView.isScrollEnabled)")
                }
            } else {
                if tableView.frame.origin.y == 0 {
                    print("tableView.frame.origin.y == 0!!!!!")
                    tableView.isScrollEnabled = true
                } else {
                    currentDrawerHeight = partialDrawerTopY + translation.y
                    tableView.isScrollEnabled = false
                    tableView.frame.origin.y = currentDrawerHeight
                }
                
            }
            
            print("")
            
            
        } else if recognizer.state == .ended {
            print("velocity.y: \(velocity.y)")
            print("tableView.contentOffset.y: \(tableView.contentOffset.y)")
            if isOpen {
                if velocity.y > 0 && tableView.contentOffset.y <= 0 { //closing drawer
                     self.closeDrawer(completion: nil)
                } else {
                    openDrawer(with: nil)
                }
            } else if !isOpen && velocity.y < 0 { //drawer is currently closed
                self.openDrawer(with: -(velocity.y))
            } else {
                if tableView.frame.origin.y > UIScreen.main.bounds.height/2 {
                    self.closeDrawer(completion: nil)
                } else {
                    self.openDrawer(with: nil)
                }
            }
        }
        self.view.layoutIfNeeded()
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer { // could be scroll or drag
//            let direction = panGesture.translation(in: view).y
//            print("in shouldRecognizeSimultaneouslyWith")
//            print("direction: \(direction)")
//            print("tableView.contentOffset.y: \(tableView.contentOffset.y)")
//            if self.isOpen {
//                print("is open")
//                if tableView.contentOffset.y == 0 && direction > 0 {
//                    tableView.isScrollEnabled = false
////                } else if tableView.contentOffset.y > 0 && direction > 0 { // drawer is open but the content is not at zero (they're somewhere in the middle or bottom of the list of results) and they're scrolling back up. We want to somehow disable the drag gesture and only enable scroll
////                    tableView.isScrollEnabled = true //test
////                    return true
//                } else {
//                    tableView.isScrollEnabled = true
////                    return true
//                }
//            } else {
//                tableView.isScrollEnabled = false
//            }
////        } else if let tapGesture = gestureRecognizer as? UITapGestureRecognizer {
////            return false
//        }
//        return true
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if let tapGesture = gestureRecognizer as? UITapGestureRecognizer, tableView.frame.contains(touch.location(in: self.view)) {
//            return true
//        }
//    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tapGesture = gestureRecognizer as? UITapGestureRecognizer, let pan = gestureRecognizer as? UIPanGestureRecognizer {
            return true
        }
        
        if gestureRecognizer == panGesture {
            if let tableViewScollPan = otherGestureRecognizer as? UIPanGestureRecognizer {
                let direction = panGesture.translation(in: view).y
                print("in shouldRequireFailureOf")
                print("direction: \(direction)")
                print("tableView.contentOffset.y: \(tableView.contentOffset.y)")
                if self.isOpen {
                    print("is open")
                    if (tableView.contentOffset.y == 0 || tableView.contentOffset.y == -20) && direction > 0 {
                        tableView.isScrollEnabled = false
                        return false
                    } else {
                        tableView.isScrollEnabled = true
                        //                    return true
                    }
                } else {
                    tableView.isScrollEnabled = false
                    return false
                }
                return true
            }
        }
        
        return false

    }
    
    
    
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //        if tableView.contentOffset.y < 0 && velocity.y < -2 {
    //            Log.info("Scrolling with sufficient velocity to show map")
    ////            toggleMap()
    //            updateMap()
    //        } else if tableView.contentOffset.y < -200 {
    //            Log.info("Scrolling far enough to show map")
    ////            toggleMap()
    //            updateMap()
    //        }
    //    }

    
    
//
//            if self.isOpen {
//                // if you're at the top of the tableview content and you're still scrolling up
//                if tableView.contentOffset.y == 0 && direction >= 0 {
//                    tableView.isScrollEnabled = false
//                } else {
//                    print("SCROLL RE-ENABLED")
//                    tableView.isScrollEnabled = true
//                    return true
//                }
//                // need to check for scrolling down and bottom of tableview
//            } else {
//                tableView.isScrollEnabled = false
//            }
//
//        }

//        return true
//    }

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//
//        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
//            let isScrollGesture = touch.view?.isDescendant(of: tableView)
//            print("isScrollGesture: \(isScrollGesture)")
//            if !isScrollGesture! { //it's a drag
//                let direction = panGesture.translation(in: view).y
//                if isOpen {
//                    print("tableView.contentOffset.y: \(tableView.contentOffset.y)")
//                    print("direction: \(direction)")
//                    if tableView.contentOffset.y == tableViewContentOffsetTop && direction <= 0 {
//                        tableView.isScrollEnabled = false
//                        return true
//                    } else {
//                        tableView.isScrollEnabled = true
//                        return false
//                    }
//                } else {
//                    tableView.isScrollEnabled = false
//                    return true
//                }
//            }
//
//
//
//
//        }
//        return true
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
//            let direction = panGesture.translation(in: view).y
////            let directionOfScroll = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: tableView).y
//            print("in shouldRequireFailureOf: tableView.contentOffset.y: \(tableView.contentOffset.y)")
//            print("directionOfPan: \(direction)")
////            print("directionOfScroll: \(directionOfScroll)")
//            if self.isOpen {
//                // if you're at the top of the tableview content and you're still scrolling up
//                if tableView.contentOffset.y == tableViewContentOffsetTop && direction >= 0 {
//                    tableView.isScrollEnabled = false
////                    panGesture.i
//                } else {
//                    print("SCROLL RE-ENABLED")
//                    tableView.isScrollEnabled = true
//                    return true
//                }
//                // need to check for scrolling down and bottom of tableview
//            } else {
//                tableView.isScrollEnabled = false
//            }
//        }
//        return false
//    }
}











//extension MapVC { //: DrawerDelegate {
//
//    func setUpBottomDrawer(placeAnnotation: PlaceAnnotation){
//
//        removeChildVC()
//
//        let drawerVC = DrawerVC()
//
//        // Create smallView
//        let drawerSmallView = PlaceSmallDrawerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 169))
////        drawerSmallView.place = placeAnnotation.place
//
//        // Create bigView
//        let drawerBigView = PlaceDetailsView(frame: self.view.frame)
////        drawerBigView.place = placeAnnotation.place
//        drawerBigView.delegate = drawerVC
//
//        drawerVC.smallView = drawerSmallView
//        drawerVC.bigView = drawerBigView
//        drawerVC.place = placeAnnotation.place
//        // Adjust bottomDrawerVC frame and initial position (below the screen)
//        drawerVC.view.frame.origin.y = self.view.frame.maxY
//
//        // Add bottomDrawerVC as a child view
//        addChildViewController(drawerVC)
//        view.addSubview(drawerVC.view)
//        UIApplication.shared.keyWindow?.insertSubview(drawerVC.view, aboveSubview: self.view)
//
//    }
//
//
//    func hideDrawer() {
//        // slide down, remove child
//        if let childVC = self.childViewControllers.last as? DrawerVC {
//            UIView.animate(withDuration: 0.3, animations: {
//                childVC.view.frame.origin.y = self.view.frame.maxY
//
//            }, completion: { (finished: Bool) in
//                self.removeChildVC()
//            })
//        }
//        tabBarController?.tabBar.isUserInteractionEnabled = true
//    }
//
//    func removeChildVC(){
//
//        for childVC in self.childViewControllers {
//            childVC.willMove(toParentViewController: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParentViewController()
//
//            print("removing last childvc")
//        }
//    }
//
//
//}



extension MapVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestCell
        cell.testTitle.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
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



