//
//  DITMonthlyManagementTableViewController.swift
//  DropIt
//
//  Created by Jin Woo Choi on 2017. 3. 22..
//  Copyright © 2017년 nathan. All rights reserved.
//

import UIKit
import CoreStore

class DITMonthlyManagementTableViewController: UITableViewController, ListSectionObserver {
    var monitor: ListMonitor<Aggregation>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Do any additional setup after loading the view.
        monitor = CoreStore.monitorList(
            From<Aggregation>(),
            OrderBy(.descending("begin")),
            Tweak { $0.fetchBatchSize = 20 }
        )
        monitor.addObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelToListViewController(segue:UIStoryboardSegue) {
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return monitor.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monitor.numberOfObjects()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DITMonthlyManagementTableViewCell.reuseId, for: indexPath)
        if let mmCell = cell as? DITMonthlyManagementTableViewCell,
            let item = monitor[safeIndexPath: indexPath] {
            mmCell.title.text = "\(item.title!)"
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let balanceSheetVC = segue.destination as? DITBalanceSheetViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
            balanceSheetVC.aggregation = monitor[selectedIndexPath.row]
        }
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<Aggregation>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Aggregation>) {
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Aggregation>) {
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Aggregation>) {
        self.tableView.reloadData()
    }

    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didInsertObject object: Aggregation, toIndexPath indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didDeleteObject object: Aggregation, fromIndexPath indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didUpdateObject object: Aggregation, atIndexPath indexPath: IndexPath) {}
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didMoveObject object: Aggregation, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableView.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Aggregation>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}
