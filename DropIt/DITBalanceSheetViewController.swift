//
//  DITBalanceSheetViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 1. 18..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import DropdownMenu
import CoreStore

class DITBalanceSheetViewController: UITableViewController, DropdownMenuDelegate {
    let paidItemCellIdentifier = "PaidItemCell"
    var numericInputCompletion: ((String, Float) -> Void)?
    var incomeItems: Array<Amount>?
    var paidItems: Array<Amount>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // for test
        let amounts = CoreStore.fetchAll(From<Amount>())
        amounts?.forEach { print($0) }
        
        incomeItems = CoreStore.fetchAll(From<Amount>(), Where("value >= 0"))
        incomeItems?.forEach { print($0.value) }
        
        paidItems = CoreStore.fetchAll(From<Amount>(), Where("value < 0"))
        paidItems?.forEach { print($0.value) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "numericInputSegue" {
            if let nvc = segue.destination as? UINavigationController,
                let numericInputVC = nvc.topViewController as? DITNumericInputViewController {
                numericInputVC.completion = numericInputCompletion
            }
        }
    }
    
    @IBAction func addButtonTouchUpInsideAction(_ sender: Any) {
        let income = DropdownItem(title: "수입")
        let paid = DropdownItem(title: "지출")
        let menuView = DropdownMenu(navigationController: navigationController!, items: [income, paid])
        menuView.displaySelected = false
        menuView.delegate = self
        menuView.showMenu()
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        numericInputCompletion = [addIncomeItem, addPaidItem][indexPath.row]
        self.performSegue(withIdentifier: "numericInputSegue", sender: self)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (incomeItems == nil ? 0 : 1) + (paidItems == nil ? 0 : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [incomeItems, paidItems][section]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paidItemCellIdentifier, for: indexPath)
        if let bsCell = cell as? DITBalanceSheetTableViewCell,
            let item = [incomeItems, paidItems][indexPath.section]?[indexPath.row] {
            bsCell.title.text = item.title
            bsCell.value.text = String(item.value)
        }
        return cell
    }
    
    func addAmount(title: String, value: Float) {
        CoreStore.beginAsynchronous {
            let amount = $0.create(Into<Amount>())
            amount.title = title
            amount.date = Date() as NSDate
            amount.value = Float(value)
            $0.commit()
        }
    }
    
    func addIncomeItem(with title: String, value: Float) {
        NSLog("addIncomeItem \(value)")
        addAmount(title: title, value: value)
    }
    
    func addPaidItem(with title: String, value: Float) {
        NSLog("addPaidItem \(value)")
        addAmount(title: title, value: -value)
    }
}
