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

enum Direction: String {
    case Income = "수입"
    case Paid = "지출"
    
    func items() -> [Direction] {
        return [.Income, .Paid]
    }
}

protocol SectionItemProtocol {
    var direction: Direction {get set}
    var items: Array<Amount> {get set}
}

struct SectionItem: SectionItemProtocol {
    var direction: Direction
    var items: Array<Amount>
    
    init(direction: Direction, items: Array<Amount>) {
        self.direction = direction
        self.items = items
    }
}

extension Array where Iterator.Element: SectionItemProtocol {
    func itemFrom(indexPath: IndexPath) -> Amount? {
        guard indexPath.section < self.count else {
            return nil
        }
        return (self[indexPath.section] as! SectionItemProtocol).items[indexPath.row]
    }
    
    func deleteItemAtIndexPath(indexPath: IndexPath) {
        guard indexPath.section < self.count else { return }
        var section = self[indexPath.section] as! SectionItemProtocol
        guard indexPath.row < section.items.count else { return }
        section.items.remove(at: indexPath.row)
    }
}


class DITBalanceSheetViewController: UITableViewController, DropdownMenuDelegate, ListObjectObserver {
    let paidItemCellIdentifier = "PaidItemCell"
    var numericInputCompletion: ((String, Float) -> Void)?
//    var incomeItems: Array<Amount>?
//    var paidItems: Array<Amount>?
    var monitor: ListMonitor<Amount>!
    
    var sections = Array<SectionItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        monitor = CoreStore.monitorSectionedList(
            From<Amount>(),
            SectionBy("value") { Int($0!)! >= 0 ? Direction.Income.rawValue : Direction.Paid.rawValue },
            OrderBy(.ascending("value")),
            Tweak { $0.fetchBatchSize = 20 }
        )
        
        // for test
        let amounts = CoreStore.fetchAll(From<Amount>())
        amounts?.forEach { print($0) }
        
        let incomeItems = CoreStore.fetchAll(From<Amount>(), Where("value >= 0"))
        incomeItems?.forEach { print($0.value) }
        
        let paidItems = CoreStore.fetchAll(From<Amount>(), Where("value < 0"))
        paidItems?.forEach { print($0.value) }
        
        if let incomes = incomeItems {
            sections.append(SectionItem(direction: .Income, items: incomes))
        }
        
        if let paids = paidItems {
            sections.append(SectionItem(direction: .Paid, items: paids))
        }
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
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].direction.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paidItemCellIdentifier, for: indexPath)
        if let bsCell = cell as? DITBalanceSheetTableViewCell,
            let item = sections.itemFrom(indexPath: indexPath) {
            bsCell.title.text = item.title
            bsCell.value.text = String(item.value)
        }
        return cell
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
        // fetchedResultController 같은 걸 써야한다.
//        let item = sections.itemFrom(indexPath: indexPath)
//        CoreStore.beginAsynchronous { (t) in
//            t.delete(item)
//            t.commit({ (r) in
//                print("d")
//            })
//        }
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//        sections.deleteItemAtIndexPath(indexPath: indexPath)
//        tableView.endUpdates()
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
    
    func listMonitor(_ monitor: ListMonitor<Amount>, didInsertObject object: Amount, fromIndexPath indexPath: IndexPath) {}
    func listMonitor(_ monitor: ListMonitor<Amount>, didDeleteObject object: Amount, fromIndexPath indexPath: IndexPath) {}
    func listMonitor(_ monitor: ListMonitor<Amount>, didUpdateObject object: Amount, fromIndexPath indexPath: IndexPath) {}
    func listMonitor(_ monitor: ListMonitor<Amount>, didMoveObject object: Amount, fromIndexPath indexPath: IndexPath) {}
}
