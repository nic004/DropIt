//
//  DITAddMonthlyManagementItemViewController.swift
//  DropIt
//
//  Created by Jin Woo Choi on 2017. 3. 22..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import PickerController
import CoreStore

class DITAddMonthlyManagementItemViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet var startDayField: UITextField!
    @IBOutlet var endDayField: UITextField!
    let dateFormat = "yyyy. MM. dd."

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
    
    func dateFrom(text: String?) -> Date? {
        guard let dateString = text else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: dateString)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let begin = dateFrom(text: startDayField.text), let end = dateFrom(text: endDayField.text) else {
            return
        }
        
        CoreStore.beginAsynchronous {
            let amount = $0.create(Into<Aggregation>())
            amount.title = self.monthField.text
            amount.begin = begin as NSDate?
            amount.end = end as NSDate?
            $0.commit()
        }
        performSegue(withIdentifier: "unwindToMonthlyManagement", sender: self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === startDayField || textField === endDayField {
            pickDateFor(textField: textField)
        } else if textField === monthField {
            pickMonthFor(textField: textField)
        }
        return false
    }
    
    func pickDateFor(textField: UITextField) {
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
        
    }
    
    func pickMonthFor(textField: UITextField) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        formatter.locale = Locale.current
        let currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
        showGroupPicker(title: "Month", groupData: [(0..<12).map { formatter.monthSymbols[$0]}], selectedIndices: [currentMonthIndex], onDone: { (indicies, items) in
            textField.text = items[0]
        }, onCancel: nil)
    }
}
