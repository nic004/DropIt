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
    
    func date(from text: String, format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: text)
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

extension String {
    func dateWith(format: String) -> Date? {
        return SharedDateFormatter.instance.date(from: self, format: format)
    }
}
