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
    var numericInputCompletion: ((Float) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // for test
        let amounts = CoreStore.fetchAll(From<Amount>())
        amounts?.forEach { print($0) }
        
        let paids = CoreStore.fetchAll(From<Amount>(), Where("value < 0"))
        paids?.forEach { print($0.value) }
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paidItemCellIdentifier, for: indexPath)
        return cell
    }
    
    func addAmount(value: Float) {
        CoreStore.beginAsynchronous {
            let amount = $0.create(Into<Amount>())
            amount.date = Date() as NSDate
            amount.value = Float(value)
            $0.commit()
        }
    }
    
    func addIncomeItem(with value: Float) {
        NSLog("addIncomeItem \(value)")
        addAmount(value: value)
    }
    
    func addPaidItem(with value: Float) {
        NSLog("addPaidItem \(value)")
        addAmount(value: -value)
    }
}
