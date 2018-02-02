//
//  PlaceSmallDrawerView.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class PlaceSmallDrawerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var openNowLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var yelpStarsImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var callButton: UIButton!

    var place: Place! {
        didSet {
            placeNameLabel.text = place.name
            if let photoRef = place.photoReference {
                PlacesClient.sharedInstance.getPhotoForReference(photoReference: photoRef, maxWidth: Int(placeImageView.frame.width), maxHeight: Int(placeImageView.frame.height), success: { (image) in
                    self.placeImageView.image = image
                }, failure: { (errorString, error) in
                    print(errorString)
                })
            }
            openNowLabel.text = place.openNow ? "Open now" : "Now closed"
            priceLabel.text = "\(place.priceLevel)"
//            for type in place.types
//
            
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
        Bundle.main.loadNibNamed("PlaceSmallDrawerView", owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setUpUI()
    }
    
    func setUpUI(){
        callButton.layer.cornerRadius = 10
    }
}
