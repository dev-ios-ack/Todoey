//
//  ViewController.swift
//  Todoey
//
//  Created by Akihito Haga on 2018/07/05.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    //var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    var itemArray = [Item]()
    
    var selectedCategory: Category?{
        didSet{
            // 値が設定されたら実行されるハンドラ（CategoryViewController で設定される）
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        searchBar.delegate = self
        
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Ternary Operator(三項演算子）
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Bool の値を反転して格納する
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        // Row 削除する場合は、Context -> ItemArray の順番で削除すると IndexPath.row がズレない
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        // Tableview を選択したとき一瞬フラッシュして元の背景色に戻る
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        /// AlertController の TextField を Grab するための変数
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            
            // AppDelegate の Singleton Instance を得る
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory  // リレーションに値を設定する
            self.itemArray.append(newItem)
            
            self.saveItems()
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
    
    //MARK: - Model Manupulation Methods
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }

    // 引数に初期値を代入することで引数を省略できる
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }

        do{
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }

}

//MARK: - Search bar methods
// Extension を使うことで ViewController の肥大化を防げる
// 機能単位にExtension することで可読性、保守性が向上する
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)   // [cd]: 大文字小文字や発音区別記号(diacritical mark)を無視する
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
}
