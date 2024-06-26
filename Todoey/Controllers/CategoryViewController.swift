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

class CategoryViewController: UITableViewController {
    
    //realm
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let swipeAction = UIContextualAction(style: .destructive, title: "Delete", handler: { contextualAction, view, actionPerformed in
            
            
            if let categoryToDelete = self.categories?[indexPath.row]{
                
                let alert = UIAlertController(title: "Delete \(categoryToDelete.name)", message: "This category contains \(categoryToDelete.items.count) Items", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                    
                    
                    do{
                        try self.realm.write {
                            if categoryToDelete.items.isEmpty{
                                self.realm.delete(categoryToDelete)
                            }else{
                                for item in categoryToDelete.items{
                                    self.realm.delete(item)
                                }
                                self.realm.delete(categoryToDelete)
                            }
                        }
                    }catch{
                        print("Error while deleting category: \(error)")
                    }
                    
                    self.tableView.reloadData()
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alert, animated: true)
                
            }else{print("else of categoryToDelete")}
        })
        swipeAction.backgroundColor = .gray
        swipeAction.image = UIImage(systemName: "trash")
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [swipeAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = true
        
        return swipeActionConfig
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let swipeAction = UIContextualAction(style: .normal, title: "Edit") { contextualAction, view, actionPerformed in
            
            let editAlert = UIAlertController(title: "Rename", message: "", preferredStyle: .alert)
            
            let actionOk = UIAlertAction(title: "Ok", style: .default) { action in
                //save changes to the name
                if let txt = editAlert.textFields?.first?.text{
                    if !txt.isEmpty{
                        
                        if let currentCategory = self.categories?[indexPath.row]{
                            
                            do{
                                try self.realm.write {
                                    currentCategory.name = txt
                                }
                                self.tableView.reloadData()
                            }catch{
                                print("error saving category context: \(error)")
                            }
                        }
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            editAlert.addAction(actionOk)
            editAlert.addAction(actionCancel)
            editAlert.addTextField { textField in
                textField.placeholder = self.categories?[indexPath.item].name
            }
            
            self.present(editAlert,animated: true)
            
        }
        swipeAction.backgroundColor = .darkGray
        swipeAction.image = UIImage(systemName: "character.cursor.ibeam")
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [swipeAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = true
        
        return swipeActionConfig
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
