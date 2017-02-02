//
//  DITNumericInputViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 2. 2..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITNumericInputViewController: UIViewController, MMNumberKeyboardDelegate {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let numberKeyboard = MMNumberKeyboard(frame: CGRect.zero)
        numberKeyboard.allowsDecimalPoint = true
        numberKeyboard.delegate = self
        textField.inputView = numberKeyboard
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: .UITextFieldTextDidChange, object: nil)
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
    
    @IBAction func cancelButtonTouchUpInsideAction(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidChange(_ sender : AnyObject) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        
        let newString = textField.text!
        let numberWithOutCommas = newString.replacingOccurrences(of: ",", with: "")
        if let number = formatter.number(from: numberWithOutCommas) {
            let formattedString = formatter.string(from: number)
            textField.text = formattedString
        } else {
            textField.text = nil
        }
    }
    
}
