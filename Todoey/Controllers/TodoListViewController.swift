//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

//because it's inhereting from UITableViewController we don't need to set any delegate

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = self.selectedCategory?.colorCode{
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
            
            if let navBarColor = UIColor(hexString: colorHex){
                
                navBar.scrollEdgeAppearance?.backgroundColor = navBarColor
                
                //color for backbutton
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                //search bar background color
                searchBar.barTintColor = navBarColor
            }
        }
    }

//    datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //here we are NOT creating a brand new cell
        //calling super class method to get the cell and adding some sauce to that cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.colorCode)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
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
    
    //MARK: - CRUD operation
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.selectedCategory?.items[indexPath.row]{
            do{
                try self.realm.write{
                    //no need to remove individually from the list of category
//                    self.selectedCategory?.items.remove(at: indexPath.row)
                    self.realm.delete(itemToDelete)
                }
            }catch{
                print("error deleting item: \(error)")
            }
        }
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
