//
//  CategoryViewController.swift
//  Todoey
//
//  Created by GurPreet SaiNi on 2024-04-03.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    //realm
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 60.0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //here we are NOT creating a brand new cell
        //calling super class method to get the cell and adding some sauce to that cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - crud operation func
    func loadCategories(){
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("error saving category context: \(error)")
        }
        //refresh table
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToDelete = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryToDelete)
                }
            }catch{
                print("error deleting category: \(error)")
            }

//                tableView.reloadData()
        }
    }

    //MARK: - addButton
    @IBAction func btnAddTouchUp(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let txt = textField.text{
                
                let newCategory = Category()
                newCategory.name = txt
                
                //save data
                self.save(category: newCategory)
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Category name"
            //put reference to global var so that we can access on other places like "Add" action
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
}

