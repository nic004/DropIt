//
//  DITPasteSNSViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 4. 6..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITPasteSNSViewController: UIViewController {
    var sms: DITSms!
    
    @IBOutlet weak var rawTextLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rawTextLabel.text = sms.raw
        sourceLabel.text = "카드/계좌: \(sms.source)"
        sourceIdLabel.text = "카드/계좌 번호: \(sms.sourceId)"
        dateLabel.text = "발생일자: \(sms.date.toString(format: "yyyy. MM. dd. HH:mm"))"
        titleLabel.text = "제목: \(sms.title)"
        amountLabel.text = "금액: \(String.formattedNumber(number: sms.amount) ?? "")"
        balanceLabel.text = "잔액/누적액: \(String.formattedNumber(number: sms.balance) ?? "")"
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
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

