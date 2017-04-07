//
//  DITSms.swift
//  DropIt
//
//  Created by nathan on 2017. 4. 7..
//  Copyright © 2017년 nathan. All rights reserved.
//

import Foundation
import AFDateHelper

protocol DITSms {
    var source: String {get set}
    var sourceId: String {get set}
    var date: Date {get set}
    var title: String {get set}
    var amount: Float {get set}
    var balance: Float {get set}
    var raw: String {get set}
}

extension DITSms {
    static func parse(raw: String) -> DITSms? {
        return nil
    }
    
}

func createSms(raw: String) -> DITSms? {
    return DITSmsHanacard.parse(raw: raw)
}

struct DITSmsHanacard: DITSms {
    var source: String
    var sourceId: String
    var date: Date
    var title: String
    var amount: Float
    var balance: Float
    var raw: String
    
    init(source: String, sourceId: String, date: Date, title: String, amount: Float, balance: Float, raw: String) {
        self.source = source
        self.sourceId = sourceId
        self.date = date
        self.title = title
        self.amount = amount
        self.balance = balance
        self.raw = raw
    }
    
    static func parse(raw: String) -> DITSms? {
        let hanaCardPattern = "\\[Web발신\\]\\s*(.+),(\\d{2}\\/\\d{2},\\d{2}:\\d{2})\\s*([\\d|\\*]+)\\s*출금([\\d,]+)원\\s*(.+)\\s*잔액([\\d,]+)원"
        let regex = try! NSRegularExpression(pattern: hanaCardPattern, options: [])
        let matches = regex.matches(in: raw, options: [], range: NSRange(location: 0, length: raw.utf16.count))
        guard matches.count > 0 && matches[0].rangeAt(0).location != NSNotFound else {
            return nil
        }
        
        let match = matches[0]
        let components = (1..<match.numberOfRanges).map { match.rangeAt($0) }.map { raw.substring(with: raw.range(from: $0)!) }
        
        guard let date = components[1].dateWith(format: "MM/dd,HH:mm")?.adjustedDate(.year, value: Date.currentYear),
            let amount = Float(components[3].replacingOccurrences(of: ",", with: "")),
            let balance = Float(components[5].replacingOccurrences(of: ",", with: "")) else {
            return nil
        }
        
        return DITSmsHanacard(source: components[0], sourceId: components[2], date: date, title: components[4], amount: amount, balance: balance, raw: raw)
    }
}
