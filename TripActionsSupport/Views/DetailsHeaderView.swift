//
//  DetailsHeaderView.swift
//  TripActionsSupport
//
//  Created by Eden on 2/2/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class DetailsHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var placeHeaderImageView: UIImageView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var placeTypeLabel: UILabel!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    func loadFromXib() {
        Bundle.main.loadNibNamed("DetailsHeaderView", owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setUpUI()
    }
    
    func setUpUI(){
        placeHeaderImageView.contentMode = .scaleAspectFill
        placeHeaderImageView.clipsToBounds = true
    }
}
