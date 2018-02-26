//
//  CategoryTableViewController.swift
//  SimpLISTic
//
//  Created by Cameron Laury on 2/22/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 85.0
        loadCategories()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new category!", message: "", preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.saveCategories(category: newCategory)
            
        }
        action.isEnabled = true
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category."
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveCategories(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    
    // Implement the DZN Dataview
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet!"
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.title = categories![indexPath.row].name
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    
    }
    
    override func updateModel(at indexPath: IndexPath) {
                
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Couldn't delete category: \(error)")
            }
        }
    }
    
}

