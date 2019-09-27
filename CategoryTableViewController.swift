//
//  CategoryTableViewController.swift
//  AV Foundation
//
//  Created by XMZ on 09/21/2019.
//  Copyright © 2019 Pranjal Satija. All rights reserved.
//

import UIKit

struct cellCategory {
    var opened = Bool()
    var title = String()
    var sectionItems = [Item]()
}

class CategoryTableViewController: UITableViewController {
    
    var categories = [cellCategory]()
    
    @IBOutlet var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the sample data.
        loadSampleItems()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories[section].opened == true ? categories[section].sectionItems.count + 1 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.textLabel?.text = categories[indexPath.section].title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 30.0)
        } else {
            cell.textLabel?.text = categories[indexPath.section].sectionItems[indexPath.row - 1].config
            cell.indentationLevel = 1
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            categories[indexPath.section].opened = !categories[indexPath.section].opened
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        } else if (indexPath.row == 1) {
            // apply config and navigate back
            // CameraController.rearCamera?
//            let data: Data! = "1".data(using: .utf8)
//            ViewController.bleControlloer.lightingCtlPeripheral.writeValue(data, for: ViewController.bleControlloer.lightingCtlChar!, type: .withResponse)
            navigationController?.popViewController(animated: true)
        } else if (indexPath.row == 2) {
           // apply config and navigate back
           // CameraController.rearCamera?
//           let data: Data! = "2".data(using: .utf8)
//           ViewController.bleControlloer.lightingCtlPeripheral.writeValue(data, for: ViewController.bleControlloer.lightingCtlChar!, type: .withResponse)
           navigationController?.popViewController(animated: true)
        } else if (indexPath.row == 3) {
           // apply config and navigate back
           // CameraController.rearCamera?
//           let data: Data! = "3".data(using: .utf8)
//           ViewController.bleControlloer.lightingCtlPeripheral.writeValue(data, for: ViewController.bleControlloer.lightingCtlChar!, type: .withResponse)
           navigationController?.popViewController(animated: true)
        }
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func loadSampleItems() {
        
        guard let item1 = Item(config: "Handbag") else {
            fatalError("Unable to instantiate item1")
        }
        guard let item2 = Item(config: "Shoe") else {
            fatalError("Unable to instantiate item2")
        }
        guard let item3 = Item(config: "Jewelry") else {
            fatalError("Unable to instantiate item3")
        }
        guard let item4 = Item(config: "Watch") else {
            fatalError("Unable to instantiate item4")
        }
        
        
        categories = [
            cellCategory(opened: false, title: "Fashion", sectionItems: [item1, item2, item3]),
            cellCategory(opened: false, title: "Office", sectionItems: [item4]),
        ]
    }
    
}
