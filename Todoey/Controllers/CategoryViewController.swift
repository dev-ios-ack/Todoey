//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Akihito Haga on 2018/07/06.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet."
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
                }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
        
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        /// AlertController の TextField を Grab するための変数
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            
            // AppDelegate の Singleton Instance を得る
            let newCategory = Category()
            newCategory.name = textField.text!

            self.save(category: newCategory)
        }
        
        //
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            // alertController にテキストフィールドが表示された段階でクロージャの外部スコープで使えるTextField変数に代入する
            textField = alertTextField
        }
        
        // Add Item Button をアラートに表示する
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        

    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
        
    }
    
}
