//
//  DITMonthlyManagementTableViewCell.swift
//  DropIt
//
//  Created by nathan on 2017. 4. 3..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITMonthlyManagementTableViewCell: UITableViewCell {
    static let reuseId = "monthlyManagementTableViewCell"
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
