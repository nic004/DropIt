//
//  DITBalanceSheetViewController.swift
//  DropIt
//
//  Created by nathan on 2017. 1. 18..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import TBDropdownMenu
import CoreStore

enum Direction: String {
    case Income = "수입"
    case Paid = "지출"
    
    func items() -> [Direction] {
        return [.Income, .Paid]
    }
}

class DITBalanceSheetViewController: UITableViewController, DropdownMenuDelegate, ListSectionObserver {
    let paidItemCellIdentifier = "PaidItemCell"
    var numericInputVCIntializer: ((DITNumericInputViewController) -> Void)?
    var monitor: ListMonitor<Amount>!
    var aggregation: Aggregation!
    
    deinit {
        monitor.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        guard let _ = aggregation.begin, let _ = aggregation.end else {
//            return
//        }
        
        // Do any additional setup after loading the view.
        monitor = CoreStore.monitorSectionedList(
            From<Amount>(),
            SectionBy("direction"),
//            Where("date >= %@", begin) && Where("date <= %@", end),
            Where("aggregation == %@", aggregation),
            OrderBy(.descending("date")),
            Tweak { $0.fetchBatchSize = 20 }
        )
        monitor.addObserver(self)
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
                numericInputVC.dependencyInjector = numericInputVCIntializer
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
        let completion = [addIncomeItem, addPaidItem][indexPath.row]
        numericInputVCIntializer = { $0.completion = completion }
        self.performSegue(withIdentifier: "numericInputSegue", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return monitor.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return monitor.sectionIndexTitles()[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monitor.numberOfObjectsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paidItemCellIdentifier, for: indexPath)
        if let bsCell = cell as? DITBalanceSheetTableViewCell,
            let item = monitor[safeIndexPath: indexPath] {
            bsCell.title.text = "\(item.title!) (\(item.date!.toString(format: "yyyy.MM.dd")))"
            bsCell.value.text = String.formattedNumber(number: item.value)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentAmount: Amount = monitor[indexPath]
        numericInputVCIntializer = {
            $0.setCurrent(title: currentAmount.title, amount: currentAmount.value, date: currentAmount.date as Date?)
            $0.completion = { (title: String, amount: Float, date: Date) in
                CoreStore.beginAsynchronous({ (t) in
                    let a = t.edit(currentAmount)!
                    a.title = title
                    a.value = amount
                    a.date = date as NSDate
                    t.commit()
                })
            }
        }
        self.performSegue(withIdentifier: "numericInputSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "해당 아이템을 삭제합니다.", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "OK", style: .destructive) { _ in self.deleteItem(indexPath: indexPath) }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteItem(indexPath: IndexPath) -> Void {
        if let item = monitor[safeIndexPath: indexPath] {
            CoreStore.beginAsynchronous { (t) in
                t.delete(item)
                t.commit()
            }
        }
    }
    
    func addAmount(title: String, value: Float, date: Date) {
        CoreStore.beginAsynchronous {
            let amount = $0.create(Into<Amount>())
            amount.title = title
            amount.date = date as NSDate
            amount.value = Float(value)
            if let agg = $0.fetchExisting(self.aggregation) {
                amount.aggregation = agg
            }
            $0.commit()
        }
    }
    
    func addIncomeItem(with title: String, value: Float, date: Date) {
        NSLog("addIncomeItem \(value)")
        addAmount(title: title, value: value, date: date)
    }
    
    func addPaidItem(with title: String, value: Float, date: Date) {
        NSLog("addPaidItem \(value)")
        addAmount(title: title, value: -value, date: date)
    }
    
//    func updateAmount(with title: String, value: Float, date: Date) {
//    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<Amount>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Amount>) {
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Amount>) {
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Amount>) {
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didInsertObject object: Amount, toIndexPath indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didDeleteObject object: Amount, fromIndexPath indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didUpdateObject object: Amount, atIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? DITBalanceSheetTableViewCell {
            let item = monitor[indexPath]
            cell.title.text = "\(item.title!) (\(item.date!.toString(format: "yyyy.MM.dd")))"
            cell.value.text = String.formattedNumber(number: item.value)
                //formatter.string(from: NSNumber(value: item.value))
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didMoveObject object: Amount, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableView.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}
