//
//  DataManager.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-14.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class DataManager: ObservableObject{
    
    @Published var inventory: [Item] = []
    @Published var inventoryHistory: [History] = []
    @Published var alerts: [Notification] = []
    @Published var people: [Person] = []
    var hasLoadedData = false

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
                            
                              let item = Item(name: name, notes: notes, amountTotal: amountTotal, amountInStock: amountInStock, category: Item.Category(rawValue: category) ?? Item.Category.office, amountHistory: amountHistory)
                              self.inventory.append(item)
                            
                          }
                      }
                  }
                  print("Fetch request")
                  hasLoadedData = true
        }
        
    }
    
    func fetchInventoryHistory(){
        inventoryHistory.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.uid)/History"
        let db = Firestore.firestore()
        let ref = db.collection(fullPath)
        let refSorted = ref.order(by: "date", descending: true)
              refSorted.getDocuments { snapshot, error in
                  guard error == nil else{
                      print(error!.localizedDescription)
                      return
                  }
                  
                  if let snapshot = snapshot{
                      for document in snapshot.documents{
                          let data = document.data()
                          let date = data["date"] as? Timestamp ?? Timestamp(date: Date.now)
                          let name = data["name"] as? String ?? ""
                          let amount = data["amount"] as? Int ?? 0
                          let added = data["added"] as? Bool ?? true
                          let person = data["person"] as? String ?? "No Person"
                        
                          let historyItem = History(itemName: name, date: date.dateValue(), addedItem: added, amount: abs(amount), person: person)
                          self.inventoryHistory.append(historyItem)
                        
                      }
                  }
              }
    }
    
    func fetchAlertHistory(){
        alerts.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.uid)/Alert"
        let db = Firestore.firestore()
        let ref = db.collection(fullPath)
        let refSorted = ref.order(by: "date", descending: true)
              refSorted.getDocuments { snapshot, error in
                  guard error == nil else{
                      print(error!.localizedDescription)
                      return
                  }
                  
                  if let snapshot = snapshot{
                      for document in snapshot.documents{
                          let data = document.data()
                          let date = data["date"] as? Timestamp ?? Timestamp(date: Date.now)
                          let name = data["name"] as? String ?? "Unknown Alert"
                          let severity = data["severity"] as? String ?? "Low"
                          let message = data["message"] as? String ?? ""
                          let seen = data["seen"] as? Bool ?? false
                          let id = data["id"] as? String ?? ""
                          let alertItem = Notification(alertType: name, alertMessage: message, severity: severity, date: date.dateValue(), seen: seen, id: id)
                          self.alerts.append(alertItem)
                      }
                  }
              }
    }
    
    func fetchPeopleData(){
        people.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.uid)/People"
        let db = Firestore.firestore()
        let ref = db.collection(fullPath)
        
        ref.getDocuments { snapshot, error in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot{
     
                for document in snapshot.documents{
                   
                    let data = document.data()
                   
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    let inventoryData = data["inventory"] as? [[String: Any]] ?? []
                    
                    var inventory:[AssignedItem] = []
                    for itemData in inventoryData {
                        let assignedFirstName = itemData["firstName"] as? String ?? ""
                        let assignedLastName = itemData["lastName"] as? String ?? ""
                        let itemID = itemData["itemID"] as? String ?? UUID().uuidString
                        let quantity = itemData["quantity"] as? Int ?? 0
                        
                        let assignedItem = AssignedItem(firstName: assignedFirstName, lastName: assignedLastName, itemID: itemID, quantity: quantity)
                        inventory.append(assignedItem)
                    }
                    
                    let person = Person(firstName: firstName, lastName: lastName,inventory: inventory)
                    self.people.append(person)
                }
            }
        }
    }
    
    
    func copyArray() -> [Item]{
        return inventory
    }
    
    func addItem(itemName: String, itemNotes: String, itemAmount: String, category: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            ref.setData(["name": itemName, "notes": itemNotes, "amountTotal": Int(itemAmount)!, "amountInStock": Int(itemAmount)!, "category": category, "amountHistory": [Int(itemAmount)]]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
        }
       
  
    }
    
    func updateItem(itemName: String, newAmount: Int, itemTotal: Int, itemHistory: [Int], person: String? = "No Person"){
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
           
            let decimalInStock = Double(newAmount)/Double(itemTotal)
            if(newAmount == 0){
                let id = UUID()
                let newPath = "Users/\(userID)/Alert/\(id)"
                let ref = db.document(newPath)
              
                ref.setData(["name": "Out of Stock", "date": Timestamp(date: Date.now), "severity": "high", "message": itemName+" is out of stock", "seen": false, "id": id.uuidString]){ error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    
                }
            }
            else if (decimalInStock <= 0.1){
                let id = UUID()
                let newPath = "Users/\(userID)/Alert/\(id)"
                
                let ref = db.document(newPath)
                ref.setData(["name": "Low Stock", "date": Timestamp(date: Date.now), "severity": "medium", "message": itemName+" is below 10% in stock", "seen": false, "id" : id.uuidString]){ error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }
            
            if(newAmount != oldAmount){
                createHistory(name: itemName, amount: difference, added: added, id: UUID(), person: person!)
            }
            
            ref.updateData(["amountInStock":newAmount, "amountTotal":itemTotal, "amountHistory": newHistory]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
            fetchItems()
            fetchAlertHistory()
           
        }
       
       
    }
    
    func updateMultipleItems(itemName: String, newAmount: Int, itemTotal: Int, itemHistory: [Int], person: String? = "No Person"){
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
           
            let decimalInStock = Double(newAmount)/Double(itemTotal)
            if(newAmount == 0){
                let id = UUID()
                let newPath = "Users/\(userID)/Alert/\(id)"
                let ref = db.document(newPath)
              
                ref.setData(["name": "Out of Stock", "date": Timestamp(date: Date.now), "severity": "high", "message": itemName+" is out of stock", "seen": false, "id": id.uuidString]){ error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    
                }
            }
            else if (decimalInStock <= 0.1){
                let id = UUID()
                let newPath = "Users/\(userID)/Alert/\(id)"
                
                let ref = db.document(newPath)
                ref.setData(["name": "Low Stock", "date": Timestamp(date: Date.now), "severity": "medium", "message": itemName+" is below 10% in stock", "seen": false, "id" : id.uuidString]){ error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }
            if(newAmount != oldAmount){
                createHistory(name: itemName, amount: difference, added: added, id: UUID(), person: person!)
            }
         
            ref.updateData(["amountInStock":newAmount, "amountTotal":itemTotal, "amountHistory": newHistory]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
           
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
        return inventory.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func createHistory(name: String, amount: Int, added: Bool, id: UUID, person: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/History/\(id)"
            let ref = db.document(fullPath)
            ref.setData(["name": name, "date": Timestamp(date: Date.now), "added": added, "amount": abs(amount), "person": person]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
        let newHistory = History(itemName: name, date: Date.now, addedItem: added, amount: abs(amount), person: person)
        inventoryHistory.append(newHistory)
    }
    
    func deleteAlert(alertID: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let newPath = "Users/\(userID)/Alert/\(alertID)"
            let ref = db.document(newPath)
            
            ref.delete(){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
        fetchAlertHistory()
    }
    
    func addPerson(firstName: String, lastName: String, inventory: [AssignedItem]){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let id = firstName + lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)
            let data: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "inventory": inventory.map{ item in
                    return[
                        "firstName": item.firstName,
                        "lastName": item.lastName,
                        "itemID": item.itemID,
                        "quantity": item.quantity
                    ] as [String : Any]
                }
            ]
            ref.setData(data){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    func updatePerson(selectedPerson: Person) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)

            let data: [String: Any] = [
                "firstName": selectedPerson.firstName,
                "lastName": selectedPerson.lastName,
                "inventory": selectedPerson.inventory.map { item in
                    return [
                        "itemID": item.itemID,
                        "quantity": item.quantity
                    ] as [String : Any]
                }
            ]

            ref.setData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addItemToPerson(person: inout Person, itemID: String, quantity: Int) {
        let newItem = AssignedItem(firstName: person.firstName,
                                   lastName: person.lastName,
                                   itemID: itemID,
                                   quantity: quantity)
        guard let item = getItemByName(name: itemID) else {
            
            return
        }
        updateItem(itemName: itemID, newAmount: item.amountInStock-quantity, itemTotal: item.amountTotal, itemHistory: item.amountHistory, person: ("\(person.firstName) \(person.lastName)"))

        person.inventory.append(newItem)

        updatePerson(selectedPerson: person)
    }
    
    func saveItemChangesPerson( items: inout [AssignedItem], person: Person){
        let changedItems = items.filter{$0.currentDifference != 0}
        
        for item in changedItems{
            let itemModelReference = getItemByName(name: item.itemID)
            updateMultipleItems(itemName: item.itemID, newAmount: (itemModelReference?.amountInStock ?? 0) - item.currentDifference, itemTotal: itemModelReference?.amountTotal ?? 0, itemHistory: itemModelReference?.amountHistory ?? [], person: ("\(person.firstName) \(person.lastName)"))
        }
        
        fetchItems()
        fetchAlertHistory()
        
        items = items.map { var mutableItem = $0; mutableItem.currentDifference = 0; return mutableItem }
    }
}
