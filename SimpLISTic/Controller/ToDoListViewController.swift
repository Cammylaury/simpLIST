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
import ChameleonFramework
import DZNEmptyDataSet

class ToDoListViewController: SwipeTableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var toDoItems: Results<Item>?
    let realm = try! Realm()

    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = 80.0

        tableView.separatorStyle = .none
        
        
        
        loadItems()

    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Get started making to do items!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Go ahead and make your first item by pressing the button below or the plus button at the top."
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let str = "Add Item"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        buttonFunctionality()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorHex = selectedCategory?.color else { fatalError() }
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist!")}
        
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
            
            navBar.barTintColor = navBarColor
            searchBar.barTintColor = navBarColor
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "54AF3F") else { fatalError()}
        
        navigationController?.navigationBar.barTintColor = originalColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {

            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            

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
    
    func buttonFunctionality() {
        
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        buttonFunctionality()
//        var textField = UITextField()
//
//        let alert = UIAlertController(title: "Add a new list item!", message: "", preferredStyle: .alert)
//
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
//
//            if let currentCategory = self.selectedCategory {
//                do {
//                    try self.realm.write {
//                        let newItem = Item()
//                        newItem.title = textField.text!
//                        newItem.dateCreated = Date()
//                        currentCategory.items.append(newItem)
//                    }
//                } catch {
//                    print("Error saving new items, \(error)")
//                }
//            }
//
//            self.tableView.reloadData()
//        }
//        action.isEnabled = true
//
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Add to your list"
//            textField = alertTextField
//        }
//
//        alert.addAction(action)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)

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





