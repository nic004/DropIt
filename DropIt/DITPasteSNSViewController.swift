//
//  DITPasteSNSViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 4. 6..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITPasteSNSViewController: UIViewController {
    var smsText: String!
    @IBOutlet weak var sourceTextLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        smsText = UIPasteboard.general.string
        sourceTextLabel.text = smsText
        parseTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func parseTest() {
//        let smsText = "[Web발신]\n하나,04/06,14:24\r\n445******08907\r\n출금6,120원\r\n네이버_LGU+\r\n잔액3,438,883원"
        let hanaCardPattern = "(\\[Web발신\\])\\s*(.+),(\\d{2})\\/(\\d{2}),(\\d{2}):(\\d{2})\\s*([\\d|\\*]+)\\s*출금([\\d\\,]+)원\\s*(.+)\\s*잔액([\\,\\d{2,3}]*)"
        let regex = try! NSRegularExpression(pattern: hanaCardPattern, options: [])
        let matches = regex.matches(in: smsText, options: [], range: NSRange(location: 0, length: smsText.characters.count))
        for i in 1..<matches[0].numberOfRanges {
            let range = matches[0].rangeAt(i)
            //    print(range.location)
            print(smsText.substring(with: smsText.range(from: range)!))
        }
        
//        let trimmed = smsText//.replacingOccurrences(of: "[\\r\\n]", with: "", options: .regularExpression, range: nil)
//        let hanaCardPattern = "(\\[Web발신\\])(.+)"
////        let hanaCardPattern = "\\[Web발신\\][\\r\\n](.+),(\\d{2})\\/(\\d{2}),\\W*(\\d{2}):(\\d{2})[\\r\\n]([\\d|\\*]+)[\\r\\n]출금([\\d\\,]+)원[\\r\\n](.+)[\\r\\n]잔액([\\d\\,]+)원"
//        let regex = try! NSRegularExpression(pattern: hanaCardPattern, options: [])
//        let matches = regex.matches(in: smsText, options: [], range: NSRange(location: 0, length: smsText.characters.count))
//        NSLog("%@", matches)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

