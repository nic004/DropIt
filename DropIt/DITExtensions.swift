//
//  DITExtensions.swift
//  DropIt
//
//  Created by nathan on 2017. 3. 21..
//  Copyright © 2017년 nathan. All rights reserved.
//

import Foundation
import AFDateHelper

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
    
    func adjustedDate(_ type: DateComponentType, value: Int) -> Date {
        return adjust(.year, offset: value - (component(type) ?? 0))
    }
    
    static func dateComponentsOfToday() -> DateComponents {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        return calendar.dateComponents([.year, .month, .day], from: Date())
    }
    
    static var currentYear: Int {
        get { return dateComponentsOfToday().year! }
    }
}

class SharedNumberFormatter {
    static let instance = SharedNumberFormatter()
    lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 10
        f.negativePrefix = ""
        return f
    }()
    private init() {}
}

extension String {
    func dateWith(format: String) -> Date? {
        return SharedDateFormatter.instance.date(from: self, format: format)
    }
    
    static func formattedNumber(number: Float) -> String? {
        return SharedNumberFormatter.instance.formatter.string(from: NSNumber(value: number))
    }
}

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
}
