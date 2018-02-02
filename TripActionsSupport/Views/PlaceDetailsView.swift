//
//  PlaceDetailsView.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class PlaceDetailsView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var place: Place!
    
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
        setUpUI()
    }
    
    func setUpUI(){
//        callButton.layer.cornerRadius = 4
    }

    
    
}
