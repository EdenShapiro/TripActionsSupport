//
//  DetailCell.swift
//  TripActionsSupport
//
//  Created by Eden on 2/2/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var yelpReviewsTextLabel: UILabel!
    @IBOutlet weak var yelpRatingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    
//    func loadFromXib() {
//        Bundle.main.loadNibNamed("DetailCell", owner: self, options: nil)
//        contentView.frame = bounds
//        addSubview(contentView)
//
//    }

}
