//
//  DITExtensions.swift
//  DropIt
//
//  Created by nathan on 2017. 3. 21..
//  Copyright © 2017년 nathan. All rights reserved.
//

import Foundation

class SharedDateFormatter {
    static let instance = SharedDateFormatter()
    let dateFormatter = DateFormatter()
    private init() {}
    
    func stringWithFormat(_ format: String, date: Date) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

extension NSDate {
    func toString(format: String) -> String {
        return SharedDateFormatter.instance.stringWithFormat(format, date: Date(timeIntervalSince1970: self.timeIntervalSince1970))
    }
}

extension Date {
    func toString(format: String) -> String {
        return SharedDateFormatter.instance.stringWithFormat(format, date: self)
    }
}
