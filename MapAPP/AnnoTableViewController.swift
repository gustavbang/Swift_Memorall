//
//  AnnoTableViewController.swift
//  MapAPP
//
//  Created by admin on 22/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class AnnoTableViewController: UITableViewController {

    var annotations = [MyAnno]()
    
    //Firebase
    var dbRef: DatabaseReference?
    var storage: Storage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase
        dbRef = Database.database().reference().child("pins")
        storage = Storage.storage()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return annotations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "annotations", for: indexPath)

        cell.textLabel?.text = annotations[indexPath.row].title
        cell.detailTextLabel?.text = annotations[indexPath.row].subtitle
        cell.textLabel?.numberOfLines = 0 // Will enable infinite length
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete")
            
            storage?.reference(forURL: (annotations[indexPath.row].imageUrl!)).delete(completion: { (error) in
                print(error ?? "no error")
            })
                dbRef?.child((annotations[indexPath.row].id)!).removeValue()
                annotations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "editAnno" {
                let destination = segue.destination as! AnnoEditTableViewController
                let indexPath = tableView.indexPathForSelectedRow
                
                let annoArray = [annotations[(indexPath?.row)!].title!, annotations[(indexPath?.row)!].subtitle!, annotations[(indexPath?.row)!].descriptionText!]
                
                destination.annoId = annotations[(indexPath?.row)!].id!
                destination.annoArray = annoArray
            }
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

}
