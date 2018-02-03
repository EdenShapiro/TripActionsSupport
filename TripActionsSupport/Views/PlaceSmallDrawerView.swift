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
    @IBOutlet weak var dot: UILabel!
    var phoneNumber: String?
    var place: Place! {
        didSet {
            if let photoRef = place.photoReference {
                PlacesClient.sharedInstance.getPhotoForReference(photoReference: photoRef, maxWidth: Int(placeImageView.frame.width), maxHeight: Int(placeImageView.frame.height), success: { (image) in
                    self.placeImageView.image = image
                    
                }, failure: { (errorString, error) in
                    print(errorString)
                })
            }
            
            placeNameLabel.text = place.name!
            openNowLabel.text = place.openNow ? "Open now" : "Now closed"
            if let price = place.priceLevel {
                priceLabel.text = String(repeating: "$", count: price)
                    dot.isHidden = false
            } else {
                priceLabel.text = ""
                dot.isHidden = true
            }
            if let types = place.types, types.count > 0 {
                // typeLabel.text = types.joined(separator: ", ") // list all types
                typeLabel.text = types[0].capitalized.components(separatedBy: CharacterSet(charactersIn: "_")).joined(separator: " ")
            } else {
                typeLabel.text = ""
            }
        }
    }
    var placeDetails: PlaceDetails? {
        didSet {
            if let phoneNumber = placeDetails?.strippedPhoneNumber{
                self.callButton.isHidden = false
                self.phoneNumber = phoneNumber
            }
            
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
        placeImageView.layer.cornerRadius = 4
        placeImageView.layer.masksToBounds = true
    }
    
    @IBAction func callButtonClicked(_ sender: Any) {
        if let number = phoneNumber {
            let url = URL(string: "telprompt://\(number)")!
            UIApplication.shared.open(url, options: [:], completionHandler: { (true) in
                print("successfully opened phone app")
            })
        }
    }
    
    
    
}
