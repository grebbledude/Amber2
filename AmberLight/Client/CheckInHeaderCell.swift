//
//  CheckInHeaderCell.swift
//  testsql
//
//  Created by Pete Bennett on 28/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class CheckInHeaderCell: UITableViewCell {

    public var section: Int?
    public var expanded = false
    public var delegate: ExpandableHeaderDelegate?
    private var first = true
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerStatusLabel: UILabel!
    
 

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func toggleOpen() {
        expanded = !expanded
        self.delegate?.sectionHeaderView(expanded: expanded, section: self.section!)
        
    }

}
