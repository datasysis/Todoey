//
//  CategoryViewController.swift
//  Todoey
//
//  Created by David Kittle on 9/6/18.
//  Copyright © 2018 David Kittle. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]() //Construct a new array of items
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
//        let category = categoryArray[indexPath.row]
//        cell.textLabel?.text = category.name
        //The two lines above were shortened to the follwoing
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        //replace the if - then - else with a ternary operator
        //cell.accessoryType = item.done == true ? .checkmark : .none
        
        //Could even be shortened more with
        //cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TabelView Delegate Methods
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            performSegue(withIdentifier: "goToItems", sender: self)

        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    //MARK - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //global text field to capture alert entry from closure
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            if textField.text! != ""{ //Text fields will NEVER be nil, but they can be an empty string, so let's check that.
                
                //New CoreData way - get a reference to the context in the AppDelegate
                
                let newCategory = Category(context: self.context)
                
                newCategory.name = textField.text!
                
                self.categoryArray.append(newCategory)
                
                self.saveCategories()
            }
    }
        //Add the textbox to the alert
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    
    //MARK: - Data Manipulation Methods

}

    func saveCategories(){
        do{
            try context.save()
        } catch {
            print ("Error during save operation: \(error)")
        }
        tableView.reloadData()
}
    //Using an external parameter (with) to make external calls read more nicely
    //We also provide a default (Category.FetchRequest()) so our call in ViewDidLoad can still function and return all records
    //Using the passed in request here will allow us to add searching like we did in the TodoList controller
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        //No longer need the next line since we are passing in a request
        //let request : NSFetchRequest<Item> = Category.fetchRequest()
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print ("Error during fetch: \(error)")
        }
        
        tableView.reloadData()
    }
}
