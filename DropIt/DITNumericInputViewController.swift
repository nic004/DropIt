//
//  DITNumericInputViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 2. 2..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import PickerController

class DITNumericInputViewController: UIViewController, MMNumberKeyboardDelegate, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    let dateFormat = "yyyy. MM. dd."
    var completion: ((String, Float, Date) -> Void)?
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
        amountField.inputView = numberKeyboard
        
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
    
    @IBAction func doneButtonTouchUpInsideAction(_ sender: Any) {
        dismiss(animated: true) {
            guard let title = self.titleTextField.text,
                let dateText = self.dateTextField.text,
                let date = dateText.dateWith(format: self.dateFormat) else {
                return
            }
            self.completion?(title, Float(self.numberWithOutCommas(text: self.amountField.text!) ?? 0), date)
        }
    }
    
    func numberWithOutCommas(text: String) -> NSNumber? {
        let numberWithOutCommas = text.replacingOccurrences(of: ",", with: "")
        return formatter.number(from: numberWithOutCommas)
    }
    
    func textFieldDidChange(_ notification : NSNotification?) {
        guard let textField = notification?.object as? UITextField, textField === amountField else {
            return
        }
        
        if let number = numberWithOutCommas(text: amountField.text!) {
            amountField.text = formatter.string(from: number)
        } else {
            amountField.text = nil
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField === dateTextField else {
            return true
        }
        
        let pickerController = PickerController_Date(title: "", onDone: {
            textField.text = $0.toString(format: self.dateFormat)
            textField.resignFirstResponder()
            }, onCancel: {
        })
        
        if let datePicker = pickerController.view.subviews[0].subviews[1] as? UIDatePicker {
            datePicker.datePickerMode = .date
        }
        
        pickerController.modalPresentationStyle = .overFullScreen
        present(pickerController, animated: false) {
            pickerController.setDate(date: Date())
        }
        
        return false
    }
    
}
