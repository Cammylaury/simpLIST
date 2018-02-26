//
//  ToDoListViewController.swift
//  SimpLISTic
//
//  Created by Cameron Laury on 2/21/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import SwipeCellKit

class ToDoListViewController: SwipeTableViewController {

    var toDoItems: Results<Item>?
    let realm = try! Realm()

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0

        loadItems()

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {

            cell.textLabel?.text = item.title

            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ??  1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }

        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add a new list item!", message: "", preferredStyle: .alert)


        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }

            self.tableView.reloadData()
        }
        action.isEnabled = true

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add to your list"
            textField = alertTextField
        }

        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

    }


    func loadItems() {

        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Couldn't delete item: \(error)")
            }
        }
    }

}

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}





