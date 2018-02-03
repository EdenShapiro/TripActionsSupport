//
//  DrawerVC.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

@objc protocol DrawerDelegate {
    func openDrawer()
    func closeDrawer(completion: (() -> Void)?)
}

class DrawerVC: UIViewController, UIGestureRecognizerDelegate, DrawerDelegate {
    
    var bigView: PlaceDetailsView!
    var smallView: PlaceSmallDrawerView!
    
    lazy var partialViewTopY = UIScreen.main.bounds.height - smallView.frame.height
    let fullViewTopY = UIScreen.main.bounds.minY
    var isOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        view.addSubview(bigView)
        view.addSubview(smallView)
        
        setUpConstraints()
        
        setUpGestureRecognizers()
        
        preloadDetails()
        
        self.view.layoutIfNeeded()
    }
    
    func setUpUI(){
        smallView.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        smallView.layer.shadowRadius = 3.0
        smallView.layer.shadowOpacity = 0.6
        smallView.layer.masksToBounds = false
    }
    
    func setUpConstraints(){
        smallView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: smallView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: smallView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        view.addConstraints([leadingConstraint, trailingConstraint])
    }
    
    func setUpGestureRecognizers(){
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        self.smallView.addGestureRecognizer(tapGesture)
    }
    
    
    func preloadDetails(){
        PlacesClient.sharedInstance.getDetailsForPlace(place: smallView.place, success: { (placeDetails) in
            self.bigView.placeDetails = placeDetails
            if let formattedPhoneNumber = placeDetails.internationalPhoneNumber {
                let nums = formattedPhoneNumber.components(separatedBy: CharacterSet(charactersIn: "+- ()"))
                self.smallView.phoneNumber = nums.joined()
            }
        }) { (errString, err) in
            print(errString)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3) { () in
            
            // set up initial short height for partial view
            self.view.frame.origin.y = self.partialViewTopY
        }
        self.bigView.alpha = 0
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //
    //        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    //
    //        UIView.animate(withDuration: 0.3, animations: { () in
    //
    //            self.view.frame.origin.y = self.view.frame.maxY
    //
    //            }, completion: { (finished: Bool) in
    //                self.bigView.removeFromSuperview()
    //                self.smallView.removeFromSuperview()
    //                self.removeChildVC()
    //            })
    //    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        self.bigView.removeFromSuperview()
        self.smallView.removeFromSuperview()
        self.removeChildVC()
    }
    
    func removeChildVC(){
        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
            print("removing children")
        }
    }
    
    func openDrawer(){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.frame.origin.y = 0
            self?.bigView.alpha = 1
            self?.smallView.alpha = 0
            self?.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.isOpen = true
                self.bigView.isUserInteractionEnabled = true
        })
        
    }
    
    func closeDrawer(completion: (() -> Void)?){
        UIView.animate(withDuration: 0.3, animations: { [weak self] () in
            self?.view.frame.origin.y = (self?.partialViewTopY)!
            self?.smallView.alpha = 1
            self?.bigView.alpha = 0
            self?.view.layoutIfNeeded()
            
            }, completion: { (finished: Bool) in
                self.isOpen = false
                self.bigView.isUserInteractionEnabled = false
        })
    }
    
    //MARK: ============ Gesture Recognizer Methods ============
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        if recognizer.state == .began {
            
        } else if recognizer.state == .changed {
            var currentDrawerHeight: CGFloat!
            let fullScreenHeight = UIScreen.main.bounds.height
            
            if isOpen {
                currentDrawerHeight = 0 + translation.y
            } else {
                currentDrawerHeight = partialViewTopY + translation.y
            }
            print("translation.y: \(translation.y)")
            print("currentDrawerHeight: \(currentDrawerHeight!)")
            print("")
            self.view.frame.origin.y = currentDrawerHeight
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.bigView.alpha = 1 - (currentDrawerHeight/fullScreenHeight)
                self?.smallView.alpha = currentDrawerHeight/fullScreenHeight
            })
            
        } else if recognizer.state == .ended {
            if velocity.y < 0 { //opening drawer
                
                self.openDrawer()

            } else { //closing drawer
                self.closeDrawer(completion: nil)
            }
        }
        
        // if the drawer is over the navbar
        if self.view.frame.origin.y < (self.navigationController?.navigationBar.frame.maxY)! {
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
        } else {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
        self.view.layoutIfNeeded()
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if !isOpen {
            openDrawer()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            print("the view that was tapped was recognized as a button")
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                return true
            } else {
                return false
            }
            
        }

        //        TODO: fix bug that lets you drag the detail view up and expose the map
        //        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
        //            //            let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        //            let direction = panGesture.velocity(in: view).y
        //            if (bigView.tableView.contentOffset.y >= (bigView.tableView.contentSize.height - bigView.tableView.frame.size.height)) && direction < 0 {
        //                return false
        //            }
        //        }
        print("In shouldReceive touch")
        return true
        
    }
    
    //    when drawer is open, drawer pangesture should be off unless user is at top of table and scrolling up
    //    when drawer is closed, tableviewscrolling should be off, and drawer pangesture should be on
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
//            if otherGesture = otherGestureRecognizer as?
            
            let direction = panGesture.velocity(in: view).y

            if self.isOpen {
                // if you're at the top of the tableview content and you're still scrolling up
                print("bigView.tableView.contentOffset.y: \(bigView.tableView.contentOffset.y)")
                if (bigView.tableView.contentOffset.y == 0 && direction > 0){
                    bigView.tableView.isScrollEnabled = false
                } else {
                    print("TABLEVIEW SCROLL IS ENABLED. bigView.tableView.contentOffset.y: \(bigView.tableView.contentOffset.y)")
                    //CHANGE LATER
                    bigView.tableView.isScrollEnabled = false
                }
                // need to check for scrolling down and bottom of tableview
            } else {
                bigView.tableView.isScrollEnabled = false
            }

        }

        return false

    }
    
}

