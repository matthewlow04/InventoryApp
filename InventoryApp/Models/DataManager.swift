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
    @Published var inventoryHistory: [History] = []
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
                              let amountInStock = data["amountInStock"] as? Int ?? 60
                              let amountTotal = data["amountTotal"] as? Int ?? 60
                              let name = data["name"] as? String ?? ""
                              let notes = data["notes"] as? String ?? ""
                              let category = data["category"] as? String ?? ""
                              let amountHistory = data["amountHistory"] as? [Int] ?? [amountTotal]
                            
                              let item = Item(name: name, notes: notes, amountTotal: amountTotal, amountInStock: amountInStock, category: category, amountHistory: amountHistory)
                              self.inventory.append(item)
                            
                          }
                      }
                  }
                  print("Fetch request")
                  hasLoadedData = true
        }
        
    }
    
//    func fetchInventoryHistory(){
//        let fullPath = "Users/\(Auth.auth().currentUser?.uid)/History"
//        let db = Firestore.firestore()
//        let ref = db.collection(fullPath)
//              ref.getDocuments { snapshot, error in
//                  guard error == nil else{
//                      print(error!.localizedDescription)
//                      return
//                  }
//                  
//                  if let snapshot = snapshot{
//                      for document in snapshot.documents{
//                          let data = document.data()
//                          let amountInStock = data["amount"] as? Int ?? 60
//                          let amountTotal = data["added"] as? Int ?? 60
//                          let name = data["name"] as? String ?? ""
//                          let notes = data["notes"] as? String ?? ""
//                          let category = data["category"] as? String ?? ""
//                          let amountHistory = data["amountHistory"] as? [Int] ?? [amountTotal]
//                        
//                          let historyItem = History(itemName: <#T##String#>, date: <#T##Date#>, addedItem: <#T##Bool#>, amount: <#T##Int#>)
//                          self.inventoryHistory.append(historyItem)
//                        
//                      }
//                  }
//              }
//    }
    
    
    func copyArray() -> [Item]{
        return inventory
    }
    
    func addItem(itemName: String, itemNotes: String, itemAmount: String, category: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
    
          
            ref.setData(["name": itemName, "notes": itemNotes, "amountTotal": Int(itemAmount), "amountInStock": Int(itemAmount), "category": category, "amountHistory": [Int(itemAmount)]]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
        }
       
  
    }
    
    func updateItem(itemName: String, newAmount: Int, itemTotal: Int, itemHistory: [Int]){
        if let currentUser = Auth.auth().currentUser{
           
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            var newHistory = itemHistory
            newHistory.append(newAmount)
            
            let oldAmount = getItemByName(name: itemName)?.amountInStock
            let difference = newAmount - oldAmount!
            var added: Bool
            
            if difference > 0{
                added = true
            }else{
                added = false
            }
            
            createHistory(name: itemName, amount: difference, added: added)
            
            ref.updateData(["amountInStock":newAmount, "amountTotal":itemTotal, "amountHistory": newHistory]){ error in
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
    
    func getItemByName(name: String) -> Item? {
        print(inventory.count)
        print(name)
        return inventory.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func createHistory(name: String, amount: Int, added: Bool){
        
        let newHistory = History(itemName: name, date: Date.now, addedItem: added, amount: abs(amount))
        inventoryHistory.append(newHistory)
    }
        
    
    
}
