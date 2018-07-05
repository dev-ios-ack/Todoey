//
//  ViewController.swift
//  Todoey
//
//  Created by Akihito Haga on 2018/07/05.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import UIKit


class TodoListViewController: UITableViewController {
    //var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath ?? "")
        
        loadItems()
        
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
            let newItem = Item()
            newItem.title = textField.text!
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
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("Error encoding item array, \(error)")
        }
        self.tableView.reloadData()
    }

    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("Error decoding item array, \(error)")
            }
        }
    }
    
}

