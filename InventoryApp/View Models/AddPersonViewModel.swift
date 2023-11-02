//
//  AddPersonViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-27.
//

import Foundation


class AddPersonViewModel: ObservableObject{
    
  
 
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var quantity = ""
    @Published var itemName = ""
    @Published var showingItems = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var selectedItem = ""
    @Published var currentAmount = [Double]()
    
    var dataManager: DataManager
    
    init(dataManager: DataManager){
        self.dataManager = dataManager
        self.currentAmount = Array(repeating: 0, count: dataManager.inventory.count)
    }
    
    func clearFields(){
        firstName = ""
        lastName = ""
        quantity = ""
    }
    
    func clearItems(){
        currentAmount = Array(repeating: 0, count: dataManager.inventory.count)
    }
    
    func checkValid() -> Bool{
        if (firstName != "" && lastName != ""){
            return true
        }
        else{
            if(firstName == ""){
                alertMessage = "You must enter a first name"
                showingAlert = true
            }else{
                alertMessage = "You must enter a last name"
                showingAlert = true
            }
            return false
        }
    }
    
    func getItemsToAdd() -> [AssignedItem]{
        let selectedItems = currentAmount.enumerated()
                .filter { $0.element > 0 }
                .map { (index, amount) in
                   
                    let itemInstance = dataManager.getItemByName(name: dataManager.inventory[index].name)
                    dataManager.updateMultipleItems(itemName: dataManager.inventory[index].name, newAmount: (itemInstance?.amountInStock ?? Int(amount)) - Int(amount), itemTotal: itemInstance?.amountTotal ?? 0 , itemHistory: itemInstance?.amountHistory ?? [], person: ("\(firstName) \(lastName)"), isFavourite: itemInstance?.isFavourite ?? false, notes: itemInstance?.notes ?? "", category: itemInstance?.category.rawValue ?? "Other", location: itemInstance!.notes, unassignedAmount: itemInstance!.amountUnassigned)
                    return AssignedItem(firstName: firstName, lastName: lastName, itemID: dataManager.inventory[index].name, quantity: Int(amount))
                }
        
        return selectedItems
    }
    
   
    
}
