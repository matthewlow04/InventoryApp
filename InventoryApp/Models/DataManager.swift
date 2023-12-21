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
    @Published var locations: [String] = []
    @Published var hasLoadedItemData = false
    @Published var hasLoadedHistoryData = false
    @Published var hasLoadedPeopleData = false
    @Published var currentNavigationView: NavigationViewType?
    
    var firstLocationFetch = true

    enum NavigationViewType {
        case inventory
        case itemView
        case other
    }
    
    func fetchItems(){
        inventory.removeAll()
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
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
                              let amountInStock = data["amountInStock"] as? Int ?? 1000 //remember
                              let amountTotal = data["amountTotal"] as? Int ?? 1000
                              let name = data["name"] as? String ?? ""
                              let notes = data["notes"] as? String ?? ""
                              let category = data["category"] as? String ?? ""
                              let amountHistory = data["amountHistory"] as? [Int] ?? [amountTotal]
                              let isFav = data["isFavourite"] as? Bool ?? false
                              let dateCreated = data["dateCreated"] as? Timestamp ?? Timestamp(date: Date.now)
                              let dateUpdated = data["dateUpdated"] as? Timestamp ?? Timestamp(date: Date.now)
                              let location = data["location"] as? String ?? "No Location"
                              let unassigned = data["unassigned"] as? Int ?? 1000
                              let url = data["link"] as? String ?? ""
                            
                              let item = Item(name: name, notes: notes, amountTotal: amountTotal, amountInStock: amountInStock, category: Item.Category(rawValue: category) ?? Item.Category.office, amountHistory: amountHistory, isFavourite: isFav, dateCreated: dateCreated.dateValue(), dateUpdated:  dateUpdated.dateValue(), location: location, amountUnassigned: unassigned, link: url)
                              self.inventory.append(item)
                            
                          }
                      }
                      self.hasLoadedItemData = true
//                      print("Fetch request")
                  }
                  
                  
        }
        
    }
    
    func fetchInventoryHistory(){
        inventoryHistory.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.email!)/History"
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
                          let id = data["id"] as? String ?? "Error"
                          let newStock = data["newStock"] as? Bool ?? false
                          let deleteStock = data["deleteStock"] as? Bool ?? false
                          let createdItem = data["createdItem"] as? Bool ?? false
                        
                          let historyItem = History(id: id, itemName: name, date: date.dateValue(), addedItem: added, amount: abs(amount), person: person, newStock: newStock, deleteStock: deleteStock, createdItem: createdItem)
                          self.inventoryHistory.append(historyItem)
                        
                      }
                  }
                  self.hasLoadedHistoryData = true
//                  print(self.inventoryHistory.count)
                  
              }
    }
    
    func fetchAlertHistory(){
        alerts.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.email!)/Alert"
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
        let fullPath = "Users/\(Auth.auth().currentUser!.email!)/People"
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
                    let isFav = data["isFavourite"] as? Bool ?? false
                    let title = data["title"] as? String ?? ""
                    var inventory:[AssignedItem] = []
                    for itemData in inventoryData {
                        let assignedFirstName = itemData["firstName"] as? String ?? ""
                        let assignedLastName = itemData["lastName"] as? String ?? ""
                        let itemID = itemData["itemID"] as? String ?? UUID().uuidString
                        let quantity = itemData["quantity"] as? Int ?? 0
                        
                        let assignedItem = AssignedItem(firstName: assignedFirstName, lastName: assignedLastName, itemID: itemID, quantity: quantity)
                        inventory.append(assignedItem)
                    }
                    
                    
                    
                    let person = Person(firstName: firstName, lastName: lastName, title: title, inventory: inventory, isFavourite: isFav)
                    self.people.append(person)
                }
            }
            print("People fetched")
            self.hasLoadedPeopleData = true
        }
    }
    
    func fetchLocations(){
        locations.removeAll()
        let fullPath = "Users/\(Auth.auth().currentUser!.email!)/Locations"
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
                    
                    let location = data["location"] as? String ?? "No Location"
                    self.locations.append(location)
                }
            }
        }
    }
    
    
    func copyArray() -> [Item]{
        return inventory
    }
    
    func addItem(itemName: String, itemNotes: String, itemAmount: String, category: String, location: String = "No Location"){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            
            ref.setData(["name": itemName, "notes": itemNotes, "amountTotal": Int(itemAmount)!, "amountInStock": Int(itemAmount)!, "category": category, "amountHistory": [Int(itemAmount)], "dateCreated": Timestamp(date: Date.now), "dateUpdated": Timestamp(date: Date.now), "location": location, "unassigned": 0]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
            
            createHistory(name: itemName, amount: Int(itemAmount)!, added: true, id: UUID().uuidString, person: "No Person", newStock: false, createdItem: true, deleteStock: false)
            
            
        }
       
  
    }
    
    func updateItem(itemName: String, newAmount: Int, itemTotal: Int, itemHistory: [Int], person: String? = "No Person", isFavourite: Bool, notes: String, category: String, newStock: Bool? = false, updateHistory: Bool? = true, location: String, unassignedAmount: Int? = 0, calledByAddItem: Bool? = false, calledByUndo: Bool? = false, skipFetch: Bool = false){
        
        if let currentUser = Auth.auth().currentUser{
           
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            var newHistory = itemHistory
           
            
           
            guard let oldAmount = getItemByName(name: itemName)?.amountInStock else {
                print("Error updating item")
                return
            }
            let difference = newAmount - oldAmount
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
                if(updateHistory!){
                    if(!calledByUndo!){
                        createHistory(name: itemName, amount: difference, added: added, id: UUID().uuidString, person: person!, newStock: newStock!, deleteStock: false)
                    }
                   
                }
                newHistory.append(newAmount)
            }
            var unassigned = unassignedAmount
            
            if(person == "No Person" && !calledByAddItem!){
                unassigned = unassignedAmount! - difference
            }
            
            var total = 0
            if(itemTotal < newAmount){
                
                total = newAmount
            }else{
                total = itemTotal
            }
            
            ref.updateData(["amountInStock":newAmount, "amountTotal":total, "amountHistory": newHistory, "isFavourite": isFavourite, "dateUpdated": Timestamp(date: Date.now), "category": category, "notes": notes, "location": location, "unassigned": unassigned!]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
            
            if(!skipFetch){
                fetchItems()
                fetchAlertHistory()
                fetchInventoryHistory()
            }
           
        }
        
        
       
       
    }
    func updateUnassigned(itemName: String, unassigned: Int){
        if let currentUser = Auth.auth().currentUser{
            
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            
            ref.updateData(["unassigned": unassigned]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addLink(itemName: String, url: String){
        if let currentUser = Auth.auth().currentUser{
            
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            
            ref.updateData(["link": url]){ error in
                print("Error setting link")
            }
            
            fetchItems()
        }
    }
    
    
    func updateMultipleItems(itemName: String, newAmount: Int, itemTotal: Int, itemHistory: [Int], person: String? = "No Person", isFavourite: Bool, notes: String, category: String, newStock: Bool? = false, updateHistory: Bool? = true, location: String, unassignedAmount: Int? = 0){
        if let currentUser = Auth.auth().currentUser{
           
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            var newHistory = itemHistory
            
            let oldAmount = getItemByName(name: itemName)?.amountInStock
            if oldAmount == nil{
                
                print("Error updating person")
                return
            }
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
                if(updateHistory!){
                    createHistory(name: itemName, amount: difference, added: added, id: UUID().uuidString, person: person!, newStock: newStock!, deleteStock: false)
                }
                newHistory.append(newAmount)
         
            }
            
            var total = 0
            if(itemTotal < newAmount){
                
                total = newAmount
            }else{
                total = itemTotal
            }
            
            var unassigned = unassignedAmount
            if(person == "No Person"){
                unassigned = unassignedAmount! - difference
            }
         
            ref.updateData(["amountInStock":newAmount, "amountTotal":total, "amountHistory": newHistory, "isFavourite": isFavourite, "dateUpdated": Timestamp(date: Date.now), "category": category, "notes": notes, "location": location, "unassigned": unassigned!]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
           
        }
       
       
    }
    
    func deleteItem(itemName: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Items/\(itemName)"
            let ref = db.document(fullPath)
            ref.delete(){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
     
            for history in inventoryHistory{
                if(history.itemName == itemName){
                    deleteHistory(id: ("\(history.id)"))
                }
            }
            
            for person in people{
                updatePersonItemDeletion(selectedPerson: person, itemName: itemName)
            }
            
            let alertId = UUID()
            let newPath = "Users/\(userID)/Alert/\(alertId)"
            
            let newRef = db.document(newPath)
            newRef.setData(["name": "Item Deleted", "date": Timestamp(date: Date.now), "severity": "low", "message": ("Item named '\(itemName)' deleted"), "seen": false, "id" : alertId.uuidString]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
            
            fetchInventoryHistory()
            fetchPeopleData()
            fetchAlertHistory()
            fetchItems()
        }
    }
    
    func checkIfExists(name: String) -> Bool{
        let results = inventory.filter {$0.name.lowercased() == name.lowercased()}
        return results.isEmpty
    }
    
    func getItemByName(name: String) -> Item? {
        return inventory.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func getPersonByName(name: String) -> Person? {
       
        return people.first { ("\($0.firstName) \($0.lastName)").lowercased() == name.lowercased()}
    }
    
    func getIndexInPersonInventory(name: String, person: Person) -> Int? {
        return person.inventory.firstIndex {$0.itemID.lowercased() == name.lowercased()}
    }
    
    func createHistory(name: String, amount: Int, added: Bool, id: String, person: String, newStock: Bool, createdItem: Bool? = false, deleteStock: Bool){
        if(amount == 0){
            return
        }
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/History/\(id)"
            let ref = db.document(fullPath)
            ref.setData(["name": name, "date": Timestamp(date: Date.now), "added": added, "amount": abs(amount), "person": person, "id": id, "newStock": newStock, "deleteStock": deleteStock, "createdItem": createdItem ?? false]) { error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
        let newHistory = History(id: id, itemName: name, date: Date.now, addedItem: added, amount: abs(amount), person: person, newStock: newStock, deleteStock: deleteStock, createdItem: createdItem!)
        inventoryHistory.append(newHistory)
    }
    
    func deleteHistory(id: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let newPath = "Users/\(userID)/History/\(id)"
            let ref = db.document(newPath)
            
            ref.delete(){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteAllHistory(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            
            let ref = db.collection("Users/\(userID)/History")

            ref.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }

                let batch = db.batch()

                snapshot?.documents.forEach { document in
                    batch.deleteDocument(ref.document(document.documentID))
                }

                // Commit the batch
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error committing batch: \(batchError.localizedDescription)")
                    } else {
                        print("Batch delete successful")
                        self.fetchInventoryHistory()
                    }
                }
            }
        }
        
    }
    
    func deleteAlert(alertID: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
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
    
    func deleteAllAlerts(){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            
            let ref = db.collection("Users/\(userID)/Alert")

            ref.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }

                let batch = db.batch()

                snapshot?.documents.forEach { document in
                    batch.deleteDocument(ref.document(document.documentID))
                }

                // Commit the batch
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error committing batch: \(batchError.localizedDescription)")
                    } else {
                        print("Batch delete successful")
                        self.fetchAlertHistory()
                    }
                }
            }
        }
        
    }
    
    func addPerson(firstName: String, lastName: String, title: String, inventory: [AssignedItem]){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
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
                    
                },
                "isFavourite": false,
                "title": title
            ]
            ref.setData(data){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    func toggleFavorite(for person: Person) {
        if let index = people.firstIndex(where: { $0.firstName+$0.lastName == person.firstName+person.lastName }) {
            people[index].isFavourite.toggle()
            updateFavouritePerson(selectedPerson: person, isFav: people[index].isFavourite)
        }
    }
    func updateFavouritePerson(selectedPerson: Person, isFav: Bool){
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)

            let data: [String: Any] = [
                "isFavourite": isFav
            ]
            ref.updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    func updatePersonTitle( selectedPerson: inout Person, title: String){
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)

            let data: [String: Any] = [
                "title": title
            ]
            
            
            ref.updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            selectedPerson.title = title
        }
    }
    func updatePerson(selectedPerson: Person) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)

            let data: [String: Any] = [
                "firstName": selectedPerson.firstName,
                "lastName": selectedPerson.lastName,
                "inventory": selectedPerson.inventory.filter{$0.quantity > 0}.map { item in
                    return [
                        "itemID": item.itemID,
                        "quantity": item.quantity
                    ] as [String : Any]
                },
                "title": selectedPerson.title
            ]

            ref.updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updatePersonItemDeletion(selectedPerson: Person, itemName:String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let newPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(newPath)

            let data: [String: Any] = [
                "firstName": selectedPerson.firstName,
                "lastName": selectedPerson.lastName,
                "inventory": selectedPerson.inventory.filter{$0.itemID.lowercased() != itemName.lowercased()}.map { item in
                    return [
                        "itemID": item.itemID,
                        "quantity": item.quantity
                    ] as [String : Any]
                }
            ]

            ref.updateData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deletePerson(selectedPerson: Person){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let id = selectedPerson.firstName + selectedPerson.lastName
            let name = "\(selectedPerson.firstName) \(selectedPerson.lastName)"
            let fullPath = "Users/\(userID)/People/\(id)"
            let ref = db.document(fullPath)
            
            var tempInventory = [AssignedItem] ()
            for item in selectedPerson.inventory{
                tempInventory.append(item)
            }
            ref.delete(){ error in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
            }
            
            for item in tempInventory{
                let itemModelReference = getItemByName(name: item.itemID)
                updateMultipleItems(itemName: item.itemID, newAmount: item.quantity + (itemModelReference?.amountInStock ?? 0), itemTotal: itemModelReference?.amountTotal ?? 0, itemHistory: itemModelReference?.amountHistory ?? [], person: ("\(selectedPerson.firstName) \(selectedPerson.lastName)"), isFavourite: itemModelReference?.isFavourite ?? false, notes: itemModelReference?.notes ?? "", category: itemModelReference?.category.rawValue ?? "Other", location: itemModelReference?.location ?? "No Location", unassignedAmount: itemModelReference!.amountUnassigned)
            }
            
            
            let alertId = UUID()
            let newPath = "Users/\(userID)/Alert/\(alertId)"
            
            let newRef = db.document(newPath)
            newRef.setData(["name": "Person Deleted", "date": Timestamp(date: Date.now), "severity": "low", "message": ("Person named '\(name)' deleted"), "seen": false, "id" : alertId.uuidString]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
            

            fetchInventoryHistory()
            print("Fetch from person delete")
            fetchPeopleData()
            fetchAlertHistory()
            fetchItems()
        }
        
    }
    
    func addItemToPerson(person: inout Person, itemID: String, quantity: Int) {
        print(itemID)
        let newItem = AssignedItem(firstName: person.firstName,
                                   lastName: person.lastName,
                                   itemID: itemID,
                                   quantity: quantity)
        guard let item = getItemByName(name: itemID) else {
            print("Item not found")
            return
        }
        updateItem(itemName: itemID, newAmount: item.amountInStock-quantity, itemTotal: item.amountTotal, itemHistory: item.amountHistory, person: ("\(person.firstName) \(person.lastName)"), isFavourite: item.isFavourite, notes: item.notes, category: item.category.rawValue, location: item.location, unassignedAmount: item.amountUnassigned)

        person.inventory.append(newItem)

        updatePerson(selectedPerson: person)
    }
    
    func saveItemChangesPerson( items: inout [AssignedItem], person: Person){
        let changedItems = items.filter{$0.currentDifference != 0}
        
        for item in changedItems{
            let itemModelReference = getItemByName(name: item.itemID)
            updateMultipleItems(itemName: item.itemID, newAmount: (itemModelReference?.amountInStock ?? 0) - item.currentDifference, itemTotal: itemModelReference?.amountTotal ?? 0, itemHistory: itemModelReference?.amountHistory ?? [], person: ("\(person.firstName) \(person.lastName)"), isFavourite: itemModelReference?.isFavourite ?? false, notes: itemModelReference?.notes ?? "", category: itemModelReference?.category.rawValue ?? "Other", location: itemModelReference?.location ?? "No Location", unassignedAmount: itemModelReference!.amountUnassigned)
        }
        
        fetchItems()
        fetchAlertHistory()
        fetchInventoryHistory()
        print("Fetch from item changes")
        
        items = items.map { var mutableItem = $0; mutableItem.currentDifference = 0; return mutableItem }
    }
    
    func addLocation(_ location: String){
        if let currentUser = Auth.auth().currentUser{
            let userID = currentUser.email!
            let db = Firestore.firestore()
            let fullPath = "Users/\(userID)/Locations/\(location)"
            let ref = db.document(fullPath)
            
            ref.setData(["location": location]){ error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
        }
       
  
    }
}
