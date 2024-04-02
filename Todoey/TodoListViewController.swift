//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

//because it's inhereting from UITableViewController we don't need to send any delegate
//userDefaults can only save default data types and can't be used with custom types

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    //to save data in Plist
    let defaults = UserDefaults.standard
    
    //file path to local storage path where we can store our apps data
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        print(dataFilePath)
        
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        itemArray.append(newItem)
//        
//        let newItem2 = Item()
//        newItem2.title = "Find Mike2"
//        itemArray.append(newItem2)
//        
//        let newItem3 = Item()
//        newItem3.title = "Find Mike3"
//        itemArray.append(newItem3)
        
//        gets data from userDefaults
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
//            itemArray = items
//        }
        
//        get data from our custom plist
        loadItems()
    }

//    datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
//    delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
        
        //to remove the grey bar selection
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //add new items
    @IBAction func btnAddTouchUp(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //open alert box with txt box and ok button
        let alert = UIAlertController(title: "Add new to do item", message: "", preferredStyle: .alert)
        
        //action button for our alert
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //once user click the add item
            
            if let txt = textField.text{
                
                let newItem = Item()
                newItem.title = txt
                
                self.itemArray.append(newItem)
                
                //saving data
                //we can't save custom object in pList/user Defaults
//                self.defaults.setValue(self.itemArray, forKey: "TodoListArray")
                
                self.saveItems()
                
                //refresh list
                self.tableView.reloadData()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(actionCancel)
        //show this alert
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(itemArray)
            if let dataPath = dataFilePath{
                try data.write(to: dataPath)
            }
        }catch{
            print("Error encoding item array: \(error)")
        }
        
    }
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("Error decoding item array: \(error)")            }
        }
    }
}

