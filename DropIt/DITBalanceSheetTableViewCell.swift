//
//  DITBalanceSheetTableViewCell.swift
//  DropIt
//
//  Created by nathan on 2017. 2. 16..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITBalanceSheetTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
