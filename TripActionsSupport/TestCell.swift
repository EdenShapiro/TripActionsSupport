//
//  TestCell.swift
//  TripActionsSupport
//
//  Created by Eden Shapiro on 2/26/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell {

    @IBOutlet weak var testTitle: UILabel!
    @IBOutlet weak var testSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
