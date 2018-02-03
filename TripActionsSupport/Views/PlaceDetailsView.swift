//
//  PlaceDetailsView.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class PlaceDetailsView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var delegate: DrawerDelegate!
    var placeDetails: PlaceDetails?
    var place: Place! {
        didSet {
            setUpUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    func loadFromXib() {
        Bundle.main.loadNibNamed("PlaceDetailsView", owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        tableView.delegate = self
//        tableView.dataSource = self
        
        let panDownToDismissGesture = UIPanGestureRecognizer(target: self, action: #selector(panDownToDismiss))
        panDownToDismissGesture.delegate = self
        self.addGestureRecognizer(panDownToDismissGesture)
        
    }
    
    func setUpUI(){
        
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "DetailCell")
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let headerView = DetailsHeaderView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 294))
        if let name = place.name {
            headerView.placeNameLabel.text = place.name!
        }
        
        if let types = place.types, types.count > 0 {
            headerView.placeTypeLabel.text = types[0].capitalized
        } else {
            headerView.placeTypeLabel.text = ""
        }
        if let photoRef = place.photoReference {
            PlacesClient.sharedInstance.getPhotoForReference(photoReference: photoRef, maxWidth: Int(self.bounds.width), maxHeight: 215, success: { (image) in
                headerView.placeHeaderImageView.image = image
            }, failure: { (errString, err) in
                print(errString)
            })
            
            tableView.tableHeaderView = headerView
        }
        
        headerView.setRadiusWithShadow()
        
        
        let leadingConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        let topConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        
        addConstraints([leadingConstraint, trailingConstraint, topConstraint])
        
        tableView.separatorStyle = .none

        
        tableView.reloadData()
        layoutIfNeeded()

    
    }
    

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DetailCell!
        
        if var c = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell {
            cell = c
        } else {
            cell = DetailCell(style: .default, reuseIdentifier: "DetailCell")
        }
        print("Switch called!")
        switch indexPath.row {
        case 0:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Pin")
            cell.infoTextLabel.text = place.formattedAddress!
            configureCellForNormalText(cell: cell)
        case 1:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Door")
            cell.infoTextLabel.text = place.openNow ? "Open now":"Now closed" //placeDetails?.openHours
            configureCellForNormalText(cell: cell)

        case 2:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Pricetag")
            if let price = place.priceLevel {
                cell.infoTextLabel.text = String(repeating: "$", count: price)
            } else {
                cell.infoTextLabel.text = ""
            }
            configureCellForNormalText(cell: cell)

        case 3:
            cell.iconImageView.image = #imageLiteral(resourceName: "Star")
            cell.infoTextLabel.isHidden = true
            cell.yelpRatingImageView.isHidden = false
            cell.yelpReviewsTextLabel.isHidden = false
            cell.accessoryType = .none
        case 4:
            cell.iconImageView.image = #imageLiteral(resourceName: "Membership Card")
            configureCellForNormalText(cell: cell)
            cell.accessoryType = .detailButton
            cell.infoTextLabel.text = "AAA, ABA, AARP, CA Farm Bureau"
            
//        case 5:
//            cell.iconImageView.image =
        default:
            cell.iconImageView.image = UIImage()
        }
        return cell
    }
    
    func configureCellForNormalText(cell: DetailCell){
        cell.infoTextLabel.isHidden = false
        cell.yelpRatingImageView.isHidden = true
        cell.yelpReviewsTextLabel.isHidden = true
        cell.accessoryType = .none
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    @objc func panDownToDismiss(sender: UIPanGestureRecognizer){
        let touchPoint = sender.location(in: self.window)

        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.frame.size.width, height: self.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
//                FIXME
//                self.dismiss(animated: true, completion: nil)
//                self.isHidden = true
                self.delegate.closeDrawer(completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                })
            }
        }
    }
}
