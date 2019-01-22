//
//  AnnoEditTableViewController.swift
//  MapAPP
//
//  Created by admin on 22/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AnnoEditTableViewController: UITableViewController {

    var annoArray = [String]() // Holds values to show in cell
    var annoId: String! // Holds ID of annotation
    var annoLabels = ["Title", "Subtitle", "Description"] // Labels for cell
    var dbRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annoArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "annoCell", for: indexPath)
 
        cell.textLabel?.text = annoLabels[indexPath.row]
        cell.detailTextLabel?.text = annoArray[indexPath.row]
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit your pin", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.annoArray[indexPath.row]
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.annoArray[indexPath.row] = alert.textFields!.first!.text!
                let dbPath = self.dbRef?.child("pins/\(self.annoId!)")

                switch self.annoLabels[indexPath.row] {
                case "Title":
                    dbPath!.child("title").setValue(self.annoArray[indexPath.row])
                    self.backToMap()
                    
                case "Subtitle":
                    dbPath!.child("subtitle").setValue(self.annoArray[indexPath.row])
                    self.backToMap()
                    
                case "Description":
                    dbPath!.child("descriptionText").setValue(self.annoArray[indexPath.row])
                    self.backToMap()

                default:
                    print("Wrong choice mate")
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })

        return [editAction]
    }
    
    // After an edit, this will take us back to our map
    func backToMap() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
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

}
