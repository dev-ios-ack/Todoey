//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Akihito Haga on 2018/07/06.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    // 引数に初期値を代入することで引数を省略できる
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
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
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategories()
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
        
    }
    
}
