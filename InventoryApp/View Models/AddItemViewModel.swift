//
//  AddItemViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import Foundation

class AddItemViewModel: ObservableObject{

    
    @Published var name = ""
    @Published var notes = ""
    @Published var numberInStock = ""
    @Published var showingAlert = false
    @Published var alertMessage = "Item added"
    @Published var selectedCategory = ""
    @Published var duplicateAlert = false
    var dataManager: DataManager
    
    init(dataManager: DataManager) {
           self.dataManager = dataManager
    }
    
    var categories: [String]{
        return ["Select"] + Item.Category.allCases.map({$0.rawValue})
    }
    
    func clearFields(){
        name = ""
        notes = ""
        numberInStock = ""
    }
    
    func checkErrors(){
        if(name != ""){
            if(Int(numberInStock) ?? 0 > 0){
                if(selectedCategory != ""){
                    if(dataManager.checkIfExists(name: name)){
                        dataManager.addItem(itemName: name, itemNotes: notes, itemAmount: numberInStock, category: selectedCategory)
                        dataManager.fetchItems()
                        alertMessage = "Item added"
                        showingAlert = true
                        print("Added")
                    }
                    else{
                        duplicateAlert = true
                    }
                }
                else{
                    alertMessage = "You must pick a category"
                    showingAlert = true
                }
                   
            }
            else{
                alertMessage = "Amount must be a positive number"
                showingAlert = true
            }
        }
        else{
            alertMessage = "You must enter a name"
            showingAlert = true
        }
    }
    
}
