//
//  ItemsTableViewController.swift
//  ToDo App
//
//  Created by echessa on 8/11/16.
//  Copyright © 2016 Echessa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ItemsTableViewController: UITableViewController {

    //let user = Auth.auth().currentUser
    var items: [ParksList] = []
    var parksModelRef: DatabaseReference!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("In Items view")
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
        let userID = Auth.auth().currentUser
        let id = userID?.uid
        self.parksModelRef = Database.database().reference(withPath: "parks-list/\(id!) ")
        
        parksModelRef.observe(.value, with: { snapshot in
            var newItems: [ParksList] = []
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let newPark = ParksList(snapshot: snapshot) {
                    newItems.append(newPark)
                }
            }
            self.items = newItems
            print("observe")
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let parkItem = items[indexPath.row]
        
        cell.textLabel?.text = switchForParkName(parkID: parkItem.parkID)
        cell.detailTextLabel?.text = "\(parkItem.ridesRidden)/\(parkItem.totalRides)"
        toggleCellCheckbox(cell, isCompleted: parkItem.favorite)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let parkItem = items[indexPath.row]
            parkItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let parkItem = items[indexPath.row]
        let toggledCompletion = !parkItem.favorite
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        parkItem.ref?.updateChildValues([
            "favorite": toggledCompletion
            ])
    }

    
    @IBAction func didTapSignOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }

    }
    
    
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
    }
    
    @IBAction func didTapAddItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new park", message: "Add the park's data", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let parkID = textField.text else { return }
            
//            let groceryItem = GroceryItem(name: text,
//                                          addedByUser: self.user.email,
//                                          completed: false)
            let newPark = ParksList(parkID: Int(parkID)!, favorite: false, ridesRidden: 0, totalRides: 0, incrementorEnabled: false)
            let newParkRef = self.parksModelRef.child(parkID.lowercased())
            newParkRef.setValue(newPark.toAnyObject())
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToParkList(segue:UIStoryboardSegue) {
        
        if let sourceViewController = segue.source as? AddParkViewController, let newPark = sourceViewController.selectedPark{
            let parkID = switchForParkID(parkName: newPark)
            let newPark = ParksList(parkID: parkID, favorite: false, ridesRidden: 0, totalRides: 0, incrementorEnabled: false)
            let newParkRef = self.parksModelRef.child(String(parkID))
            newParkRef.setValue(newPark.toAnyObject())
        }
        
    }
    func switchForParkID(parkName: String) -> Int{
        var parkID = 0
        switch parkName {
        case "Magic Kingdom":
            parkID = 1
        case "EPCOT":
            parkID = 2
        case "Animal Kingdom":
            parkID = 3
        case "Busch Gardens":
            parkID = 4
        case "Hollywood Studios":
            parkID = 5
        case "Universal Studios Orlando":
            parkID = 6
        case "Seaworld Orlando":
            parkID = 7
        case "Islands of Adventure":
            parkID = 8
        default:
            parkID = 0
        }
        return parkID
    }
    
    func switchForParkName(parkID: Int) -> String{
        var parkName = ""
        switch parkID {
        case 1:
            parkName = "Magic Kingdom"
        case 2:
            parkName = "EPCOT"
        case 3:
            parkName = "Animal Kingdom"
        case 4:
            parkName = "Busch Gardens"
        case 5:
            parkName = "Hollywood Studios"
        case 6:
            parkName = "Universal Studios Orlando"
        case 7:
            parkName = "Seaworld Orlando"
        case 8:
            parkName = "Islands of Adventure"
        default:
            parkName = "Bad parkID"
        }
        return parkName
    }
}
