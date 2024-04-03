//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift

//because it's inhereting from UITableViewController we don't need to set any delegate

class TodoListViewController: UITableViewController {

    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //not loading here as it should load only if selectedCategory is not nil
        //loadItems()
    }

//    datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items added yet!"
        }
        
        return cell
    }
    
//    delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error updating items: \(error)")
            }
        }
        
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
            
            if let txt = textField.text, let currentCategory = self.selectedCategory{
                
                do{
                    try self.realm.write {
                        
                        let newItem = Item()
                        newItem.title = txt
                        newItem.dateCreated = Date()
                        
                        //adding this new item to the list of our categories
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items: \(error)")
                }
                
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
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

//MARK: - SearchBarDelegate
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //cd - case and diacritic(asscent) insensitive
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            print("should clear filter")
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
