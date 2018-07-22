//
//  ViewController.swift
//  Todoey
//
//  Created by Akihito Haga on 2018/07/05.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    //var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    
    var selectedCategory: Category?{
        didSet{
            // 値が設定されたら実行されるハンドラ（CategoryViewController で設定される）
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.separatorStyle = .none
        
    }
    
    // NavigationController 関連の処理は viewWillApper で行う必要がある（DidLoadだとNavigationController が nil であるため）
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.backgroundColor else { fatalError() }
        updateNavBar(withHexCode: colorHex)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else { fatalError("navigation controller dose not exist.") }
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }

        navBar.barTintColor = navBarColor   // NavBar の背景色
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)   // NavBar 戻るボタンの色
        navBar.largeTitleTextAttributes = [ NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]  // NabBar タイトルの文字色
        searchBar.barTintColor = navBarColor // 検索バーの背景色
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
//
//        if let item = todoItems?[indexPath.row] {
//            cell.textLabel?.text = item.title
//            // Ternary Operator(三項演算子）
//            cell.accessoryType = item.done ? .checkmark : .none
//        }else{
//            cell.textLabel?.text = "No Items Added."
//        }
//
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count) ){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            print("Version1: ", CGFloat(indexPath.row / todoItems!.count))
            print("Version2: ", CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            // Ternary Operator(三項演算子）
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added."
        }
        return cell
    }

    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status,  \(error)")
            }
        }
        
        tableView.reloadData()

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
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items,  \(error)")
                }
            }
            
            self.tableView.reloadData()

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

    // 引数に初期値を代入することで引数を省略できる
    func loadItems(){

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting todoitem\(error)")
            }
        }
    }

}

//MARK: - Search bar methods
// Extension を使うことで ViewController の肥大化を防げる
// 機能単位にExtension することで可読性、保守性が向上する
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
            
        tableView.reloadData()
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
