//
//  DITAddMonthlyManagementItemViewController.swift
//  DropIt
//
//  Created by Jin Woo Choi on 2017. 3. 22..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import PickerController

class DITAddMonthlyManagementItemViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var startDayField: UITextField!
    @IBOutlet var endDayField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let pickerController = PickerController_Date(title: "", onDone: { [unowned self] (date) in
            textField.text = date.toString(format: "yyyy. MM. dd.")
            textField.resignFirstResponder()
            if textField === self.startDayField && (self.endDayField.text ?? "").isEmpty {
//                self.endDayField.text =
                if let monthMoved = Calendar.current.date(byAdding: .month, value: 1, to: date),
                    let dayMoved = Calendar.current.date(byAdding: .day, value: -1, to: monthMoved) {
                    self.endDayField.text = dayMoved.toString(format: "yyyy. MM. dd")
                }
            }
            
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
