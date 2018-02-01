//
//  SearchBarsView.swift
//  TripActionsSupport
//
//  Created by Eden on 1/31/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class SearchBarsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placesSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    func loadFromXib() {
        Bundle.main.loadNibNamed("SearchBarsView", owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        placesSearchBar.layer.borderWidth = 1
        placesSearchBar.layer.borderColor = UIColor.white.cgColor
        placesSearchBar.autocorrectionType = .yes
        locationSearchBar.layer.borderWidth = 1
        locationSearchBar.layer.borderColor = UIColor.white.cgColor
        locationSearchBar.autocorrectionType = .yes

    }

}
