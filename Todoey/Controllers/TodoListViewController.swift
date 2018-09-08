//
//  ViewController.swift
//  Todoey
//
//  Created by David Kittle on 8/31/18.
//  Copyright © 2018 David Kittle. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]() //Construct a new array of items
    
    //This bit sets a local variable to capture the selected catagory (an optional becuase it can be nil) from the category view controller
    //and if it is set (didSet) then it will immediately run the loadItems() function
    //Since we are doing this here, we can remove the loadItmes() call from viewDidLoad
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Start using Standard User Defaults framwork
    //Remarked out for NSCode usage
    //var defaults = UserDefaults.standard
    
    //Create global constant for path to our own custom app plist for our custom item class
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadItems()
        
        //This can be (and was) accomplished by control dragging the
        //search bar (after creating the IBOutlet above), to ViewController icon at the top of the view controller
        //searchBar.delegate = self

    }
    
    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //replace the if - then - else with a ternary operator
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        //Could even be shortened more with
        //cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
        
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //Code to delete the items rather than just giving them a checkbox
        //Delete from the database FIRST
        context.delete(itemArray[indexPath.row])
        //Then delete from our tableView
        itemArray.remove(at: indexPath.row)
        
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() //global text field to capture alert entry from closure
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if textField.text! != ""{ //Text fields will NEVER be nil, but they can be an empty string, so let's check that.
                
                //New CoreData way - get a reference to the context in the AppDelegate
                
                let newItem = Item(context: self.context)
                
                newItem.title = textField.text!
                newItem.done = false
                //set the parent category for the item
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                self.saveItems()
            }
            
        }
        
        //Add the textbox to the alert
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        do{
            try context.save()
        } catch {
            print ("Error during save operation: \(error)")
        }
        tableView.reloadData()
    }
    
    //Using an external parameter (with) to make external calls read more nicely
    //We also provide a default (Item.FetchRequest()) so our call in ViewDidLoad can still function and return all records
    //We added the passed in request to facilitate the search capabilities below.
    //Adding an additional default predicate arg to enable our search while we are also passing in our category
    //The new predicate arg is an optional that can be nil (no search was done)
    //We will now use a compound predicate to filter on both category and any search parameters sent
    //Again, defaulting the new predicate arg let's our original loadItems() calls still work
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let searchPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,searchPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print ("Error during fetch: \(error)")
        }
        
        tableView.reloadData()
    }
    
}

//To avoid stacking up a gazillion delegates and classes in the main class header above,
//you can use extensions to better extend and organize your code!
//MARK - Search Bar Extension (Delegate) Methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //Use a predicate to query the data based on the search term
        //The "[cd]" makes the search NOT case senstitve and NOT diacritic
        
        //let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //Add the query to our request
        //request.predicate = predicate
        //We refactored the code above to:
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //request.sortDescriptors = [sortDescriptor] //Accepts an ARRAY of sort descriptors - we are just send one for now.
        //We refactored the code above to:
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //Load our items!
        //We refactored our code to convert this to call to the loadItems function above
        //We added a parameter the function above to accept the request (as NSFetchRequest) that was initialized above
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print ("Error during fetch: \(error)")
//        }
        //The function above uses an external parameter (called "with") so external calls read more nicely
        loadItems(with: request, predicate: predicate)
        
        //No longer need this since we are now using a funciton that calls the reload for us!
        //tableView.reloadData()
        
    }
    
    //This function basically implements a progressive search while typing in the search bar fiel
    //and/or a total reload of the list from the database when the "x" clear button on the search bar is clicked
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0{
            loadItems() //simply call loadItems() with no paramter to reload the entire list.
            
            //Make sure we get the main thread before we resignFirstRepsonder
            //This is so we don't have to wait for other tasks to finish before the keyboard goes away
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //Causes the keyboard to go away
            }
            
        }
    }
    
}

