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
    var hasLoadedData = false

//
//    init(){
//       hasLoadedData = true
//
//    }
//    
    func fetchItems(){
        inventory.removeAll()
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items"
            let ref = db.collection(fullPath)
                  ref.getDocuments { snapshot, error in
                      guard error == nil else{
                          print(error!.localizedDescription)
                          return
                      }
                      
                      if let snapshot = snapshot{
                          for document in snapshot.documents{
                              let data = document.data()
                              let amountInStock = data["amountInStock"] as? Int ?? 50
                              let amountTotal = data["amountTotal"] as? Int ?? 50
                              let name = data["name"] as? String ?? ""
                              let notes = data["notes"] as? String ?? ""
                           
                            
                              let item = Item(name: name, notes: notes, amountTotal: amountTotal, amountInStock: amountInStock)
                              self.inventory.append(item)
                            
                          }
                      }
                  }
                  print("Fetch request")
                  hasLoadedData = true
        }
        
    }
    
    
    func copyArray() -> [Item]{
        return inventory
    }
    
    func addItem(itemName: String, itemNotes: String, itemAmount: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
    
          
            ref.setData(["name": itemName, "notes": itemNotes, "amountTotal": Int(itemAmount), "amountInStock": Int(itemAmount)]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
        }
       
  
    }
    
    func updateItem(itemName: String, itemStock: Int){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            ref.updateData(["amountInStock":itemStock]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
            fetchItems()
        }
       
       
    }
    
    func deleteItem(itemName: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            ref.delete(){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
            fetchItems()
        }
    }
    
    
    func checkIfExists(name: String) -> Bool{
        let results = inventory.filter {$0.name == name}
        return results.isEmpty
    }
    
        
    
    
}
