//
//  Amount+Ext.swift
//  DropIt
//
//  Created by nathan on 2017. 3. 21..
//  Copyright © 2017년 nathan. All rights reserved.
//

import Foundation

extension Amount {
    func direction() -> String {
        return value >= 0 ? Direction.Income.rawValue : Direction.Paid.rawValue
    }
}
