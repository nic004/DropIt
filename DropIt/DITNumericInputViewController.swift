//
//  DITNumericInputViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 2. 2..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit

class DITNumericInputViewController: UIViewController, MMNumberKeyboardDelegate, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textField: UITextField!
    
    var completion: ((String, Float) -> Void)?
    lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 10
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let numberKeyboard = MMNumberKeyboard(frame: CGRect.zero)
        numberKeyboard.allowsDecimalPoint = true
        numberKeyboard.delegate = self
        textField.inputView = numberKeyboard
        textField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
    
    func numberWithOutCommas(text: String) -> NSNumber? {
        let numberWithOutCommas = text.replacingOccurrences(of: ",", with: "")
        return formatter.number(from: numberWithOutCommas)
    }
    
    func textFieldDidChange(_ sender : AnyObject) {
        if let number = numberWithOutCommas(text: textField.text!) {
            textField.text = formatter.string(from: number)
        } else {
            textField.text = nil
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NSLog(textField.text!)
        dismiss(animated: true) {
            if let title = self.titleTextField.text {
                self.completion?(title, Float(self.numberWithOutCommas(text: textField.text!) ?? 0))
            }
        }
    }
    
}
