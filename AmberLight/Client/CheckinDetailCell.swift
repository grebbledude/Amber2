//
//  CheckinDetailViewCell.swift
//  testsql
//
//  Created by Pete Bennett on 28/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class CheckinDetailCell: UITableViewCell {

    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailStatusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
