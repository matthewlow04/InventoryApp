//
//  DataManager.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-14.
//

import SwiftUI
import Firebase

class DataManager: ObservableObject{
    @Published var inventory: [Item] = []
    
//    init(){
//        fetchItems()
//    }
    
    func fetchItems(){
        inventory.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Items")
        ref.getDocuments { snapshot, error in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot{
                for document in snapshot.documents{
                    let data = document.data()
                    let notes = data["notes"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let item = Item(name: name, notes:notes)
                    self.inventory.append(item)
                }
            }
        }
    }
    
    func copyArray() -> [Item]{
        return inventory
    }
    
    func addItem(itemName: String, itemNotes: String){
        let db = Firestore.firestore()
        let ref = db.collection("Items").document(itemName)
        ref.setData(["name":itemName, "notes":itemNotes]){ error in
            if let error = error{
                print(error.localizedDescription)
            }
            
        }
    }
    
    func checkIfExists(name: String) -> Bool{
        let results = inventory.filter {$0.name == name}
        return results.isEmpty
    }
    
    
    
}
