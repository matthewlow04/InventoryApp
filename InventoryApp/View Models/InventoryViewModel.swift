//
//  InventoryViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import Foundation

class InventoryViewModel: ObservableObject{
  
    
    @Published var localInventory = [Item]()
    
    init(){
        let dataManager = DataManager()
        localInventory = dataManager.inventory
    }
    
    
    func addItem(name: String, notes: String, total: String){
        let item = Item(name:name, notes:notes, amountTotal: Int(total)!,amountInStock: Int(total)!)
        localInventory.append(item)
    }
    
    func checkIfExists(name: String) -> Bool{
        print("Check if exists called")
        let results = localInventory.filter {$0.name == name}
        return results.isEmpty
    }
}
