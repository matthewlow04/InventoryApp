//
//  HistoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-25.
//

import SwiftUI

struct HistoryView: View {
    @State var helpAlertShowing = false
    @State var searchText = ""
    @State var showingActionSheet = false
    @State var showingConfirmation = false
    @State var showingErrorAlert = false
    @State var selectedHistoryItem: History?
    @State var errorMessage = "Unknown Error"
    @State var isLoadingScreen = false
    var filteredHistory: [History] {
        if searchText.isEmpty {
            return dataManager.inventoryHistory
        } else {
            return dataManager.inventoryHistory
                .filter { $0.itemName.lowercased().contains(searchText.lowercased()) || $0.person.lowercased().contains(searchText.lowercased()) }
        }
    }
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack{
            if(!$dataManager.hasLoadedHistoryData.wrappedValue || isLoadingScreen){
                ProgressView()
                    .navigationTitle("Inventory History")
            }
            else if(dataManager.inventoryHistory.isEmpty){
                Text("No inventory history")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
                    .navigationTitle("Inventory History")
            }else{
                List(filteredHistory, id: \.self){ item in
                   
                    Button {
                        selectedHistoryItem = item
                        showingActionSheet = true
                    } label: {
                        HStack{
                            VStack(alignment: .leading, spacing: 10){
                                Text(item.itemName)
                                    .bold()
                                if(item.newStock){
                                    Text("\(item.addedItemString(item.addedItem)) \(item.amount) (New Stock)")
                                }else if(item.createdItem){
                                    Text("\(item.addedItemString(item.addedItem)) \(item.amount) (Item Created)")
                                }
                                else{
                                    Text("\(item.addedItemString(item.addedItem)) \(item.amount)")
                                }
                                
                            }
                            Spacer()
                            VStack(alignment: .trailing){
                                HStack{
                                    Image(systemName: appendedText(hist: item))
                                    Text(item.person)
                                }
                                
                                Text(timeSince(date: item.date))
                                    .foregroundColor(.gray)
                                    .italic()
                            }

                           
                        }
                        
                       
                        
                    }
                    .disabled(false)
                    
                    .confirmationDialog("Actions", isPresented: $showingActionSheet) {
                        Button("Delete History"){
                            isLoadingScreen = true
                            dataManager.deleteHistory(id: selectedHistoryItem!.id)
                            dataManager.fetchInventoryHistory()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                                isLoadingScreen = false
                            }
                        }
                        
                        Button("Undo Change"){
                          
                            let itemInstance = dataManager.getItemByName(name: item.itemName)
                            
                            //if there's a person
                            if(selectedHistoryItem!.person != "No Person"){
                                guard var person = dataManager.getPersonByName(name: selectedHistoryItem!.person) else{
                                    showError("This person no longer exists")
                                    return
                                }
                                let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) ?? -1
                                
                                //undo item is taken from inventory
                                if(!selectedHistoryItem!.addedItem){
                                    
                                    //if item not in person inventory anymore
                                    if(index == -1){
                                        showError("Undo failed. This person no longer has this item")
                                        return
                                    }
                                    
                                    //person doesn't have enough items
                                    if(selectedHistoryItem!.amount > person.inventory[index].quantity){
                                        showError("Person doesn't have enough items to undo")
                                        return
                                    }
                                    
                                    // undo causes too many items
                                    if(selectedHistoryItem!.amount + itemInstance!.amountInStock > itemInstance!.amountTotal){
                                        showError("You can't undo because there will be more items in stock than in circulation")
                                        return
                                    }
                                    
                                    dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                           newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount,
                                                           itemTotal: itemInstance!.amountTotal,
                                                           itemHistory: itemInstance!.amountHistory,
                                                           person: person.firstName + " " + person.lastName,
                                                           isFavourite: itemInstance!.isFavourite,
                                                           notes: itemInstance!.notes,
                                                           category: itemInstance!.category.rawValue,
                                                           location: itemInstance!.location, 
                                                           unassignedAmount: itemInstance!.amountUnassigned,
                                                           calledByUndo: true,
                                                           skipFetch: true
                                    )
                                    
//                                    update person inventory
                                    
                                    person.inventory[index].quantity =  person.inventory[index].quantity - selectedHistoryItem!.amount
                                    dataManager.updatePerson(selectedPerson: person)
                                }
                                
                                //undo item is given back to inventory
                                else{
                                    if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
                                        showError("Not enough in inventory to undo")
                                        return
                                    }
                                    
                                    //if the history was a new item add
                                    if(selectedHistoryItem!.newStock){
                                        if(itemInstance!.amountTotal - selectedHistoryItem!.amount < 0){
                                            showError("Not enough in stock to undo")
                                            return
                                        }
                                       
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal - selectedHistoryItem!.amount,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               person: person.firstName + " " + person.lastName,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned,
                                                               calledByUndo: true,
                                                               skipFetch: true
                                                               
                                        )
                                    }
                                    
                                    //if it wasn't a new addition of stock
                                    else{
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               person: person.firstName + " " + person.lastName,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned,
                                                               calledByUndo: true,
                                                               skipFetch: true
                                                               
                                        )
                                    }
                                   
                                  
                                            
                                    if let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) {
                                        // Item found in person's inventory, update quantity
                                        person.inventory[index].quantity =  person.inventory[index].quantity + selectedHistoryItem!.amount
                                        dataManager.updatePerson(selectedPerson: person)
                                    } else {
                                        // Item not found, add it to the person's inventory
                                        dataManager.addItemToPerson(person: &person, itemID: selectedHistoryItem!.itemName, quantity: selectedHistoryItem!.amount)
                                    }
                                    
                                    
                                    
                                }
                                isLoadingScreen = true
                                dataManager.fetchItems()
                                dataManager.fetchPeopleData()
                                dataManager.fetchInventoryHistory()
                                dataManager.fetchAlertHistory()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                                    isLoadingScreen = false
                                }
                            }
                            
                            //no person
                            else{
                                //undo add from inventory
                                if(selectedHistoryItem!.addedItem){
                                    if(selectedHistoryItem!.amount > itemInstance!.amountInStock){
                                        showError("Not enough items in inventory to undo")
                                        return
                                    }
                                    
                                    //new stock
                                    if(selectedHistoryItem!.newStock){
                                        if(selectedHistoryItem!.amount > itemInstance!.amountTotal){
                                            showError("Not enough items in total to undo")
                                            return
                                        }
                                        
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal - selectedHistoryItem!.amount,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               newStock: true,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned,
                                                               calledByAddItem: true,
                                                               calledByUndo: true
                                        )
                                        
                                    }
                                    
                                    
                                    //not new stock
                                    else{
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned,
                                                               calledByUndo: true
                                        )
                                    }
                                }
                                //undo subtract from inventory
                                else{
                                    if(itemInstance!.amountInStock + selectedHistoryItem!.amount > itemInstance!.amountTotal){
                                        showError("Not enough items in circulation to undo")
                                        return
                                    }
                                    dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                           newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount,
                                                           itemTotal: itemInstance!.amountTotal,
                                                           itemHistory: itemInstance!.amountHistory,
                                                           isFavourite: itemInstance!.isFavourite,
                                                           notes: itemInstance!.notes,
                                                           category: itemInstance!.category.rawValue,
                                                           location: itemInstance!.location,
                                                           unassignedAmount: itemInstance!.amountUnassigned,
                                                           calledByUndo: true
                                    )
                                }
                                isLoadingScreen = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                                    isLoadingScreen = false
                                }

                            }
                            dataManager.deleteHistory(id: selectedHistoryItem!.id)

                        }
                        .disabled(true)
//                        .disabled((selectedHistoryItem?.createdItem ?? true) ? true : false)

                        Button("Duplicate Change"){
                          
                            let itemInstance = dataManager.getItemByName(name: selectedHistoryItem!.itemName)
                            
                            //Person Exists
                            if(selectedHistoryItem!.person != "No Person"){
                                guard var person = dataManager.getPersonByName(name: selectedHistoryItem!.person) else{
                                    showError("This person no longer exists")
                                    return
                                }
                                let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) ?? -1
                                
                                //if an item is taken away check if the person has enough inventory to perform this action
                                
                                //item subtracted from inventory to person
                                if(!selectedHistoryItem!.addedItem){
                                   
                                    //if it wasn't newly added
                                    if(!selectedHistoryItem!.newStock){
                                        
                                        
                                        //check if there's enough inventory to give to person
                                        if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
                                            showError("Not enough in inventory to duplicate this change")
                                            return
                                        }
                                        
                                        //update item
                                        
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName, 
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               person: person.firstName + " " + person.lastName,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned,
                                                               skipFetch: true
                                                               
                                        )
                                        
                                        //update person inventory
                                            
                                        if(index != -1){
                                            print(selectedHistoryItem!.amount)
                                            print(person.inventory[index].quantity) //issue here
                                            person.inventory[index].quantity =  person.inventory[index].quantity + selectedHistoryItem!.amount
                                            print(person.inventory)
                                            dataManager.updatePerson(selectedPerson: person)
                                        }
                                        else{
                                            dataManager.addItemToPerson(person: &person, itemID: selectedHistoryItem!.itemName, quantity: selectedHistoryItem!.amount)
                                        }
                        
                                        
                                       
                                    }
                                    //if that was a newly added item(can't happen as of right now)
                                    
                                    else{
                                        showError("Error!")
                                    }
                                        
                                }
                                //item added to inventory from person
                                else{
                                    
                                    //check if person has in inventory
                                    if(index == -1){
                                        showError("Person no longer has this item")
                                        return
                                        
                                    }
                                    
                                    // check if person has enough inventory
                                    if(person.inventory[index].quantity - selectedHistoryItem!.amount < 0){
                                        showError("Person doesn't have enough of this item to duplicate this change")
                                        return
                                    }
                                    
                                  
                                    
                                    if(itemInstance!.amountInStock + selectedHistoryItem!.amount > itemInstance!.amountTotal){
                                        showError("You are returning more items to inventory than exist in circulation")
                                    }
                                    
                                    //update item
                                    
                                    dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                           newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount,
                                                           itemTotal: itemInstance!.amountTotal,
                                                           itemHistory: itemInstance!.amountHistory,
                                                           person: person.firstName + " " + person.lastName,
                                                           isFavourite: itemInstance!.isFavourite,
                                                           notes: itemInstance!.notes,
                                                           category: itemInstance!.category.rawValue,
                                                           location: itemInstance!.location,
                                                           unassignedAmount: itemInstance!.amountUnassigned,
                                                           skipFetch: true
                                    )
                                    
                                    //update person inventory
                                    
                                    person.inventory[index].quantity =  person.inventory[index].quantity - selectedHistoryItem!.amount
                                    dataManager.updatePerson(selectedPerson: person)
                                  
                                }
                                
                                isLoadingScreen = true
                                dataManager.fetchItems()
                                dataManager.fetchPeopleData()
                                dataManager.fetchInventoryHistory()
                                dataManager.fetchAlertHistory()
                                
                            
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                                    isLoadingScreen = false
                                }

                                
                            }
                            //Person does not exist
                            else{
                                //item is subtracted from inventory
                                if(!selectedHistoryItem!.addedItem){
                                    
                                    //if not enough inventory return
                                    if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
                                        showError("Not enough in inventory to duplicate this change")
                                        return
                                    }
                                    //else update
                                    else{
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock - selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned
                                        )
                                    }
                                 
                                                                    }
                                
                                //item is added back to inventory
                                else{
                                    
                                    if(!selectedHistoryItem!.newStock){
                                        
                                        //if more inventory overflow return
                                        if(itemInstance!.amountInStock + selectedHistoryItem!.amount > itemInstance!.amountTotal){
                                            showError("You are returning more items to inventory than exist in circulation")
                                            return
                                        }
                                        
                                        //else update
                                       
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               location: itemInstance!.location,
                                                               unassignedAmount: itemInstance!.amountUnassigned
                                                               
                                        )
                                        
                                    }
                                    
                                    //item is new stock
                                    
                                    else{
                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName,
                                                               newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount,
                                                               itemTotal: itemInstance!.amountTotal + selectedHistoryItem!.amount,
                                                               itemHistory: itemInstance!.amountHistory,
                                                               isFavourite: itemInstance!.isFavourite,
                                                               notes: itemInstance!.notes,
                                                               category: itemInstance!.category.rawValue,
                                                               newStock: true,
                                                               location: itemInstance!.location,
                                                               calledByAddItem: true
                                        )
                                    }
                                    
                                    
                                }
                                isLoadingScreen = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                                    isLoadingScreen = false
                                }

                            }
                        }
                        .disabled(true)
                    }
                    .foregroundStyle(Color.black)

                   
                   
                }
                .alert("The arrow right means the person is receiving items from inventory, the arrow left means the items are going back to inventory", isPresented: $helpAlertShowing){
                    Button("OK", role: .cancel){}
                }
                .alert(errorMessage, isPresented: $showingErrorAlert){
                    Button("OK", role: .cancel){}
                }
                .searchable(text: $searchText)
                .navigationTitle("Inventory History")
                .toolbar{
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button(action: {
                           helpAlertShowing = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Clear All History"){
                            showingConfirmation = true
                        }
                        .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
                            Button("Delete all inventory history?", role: .destructive) {
                                dataManager.deleteAllHistory()
                            }
                        }
                    }
                    
                }
            }
            
            
        }
        .onAppear{
            dataManager.hasLoadedHistoryData = false
            dataManager.fetchInventoryHistory()
        }
    }
    
    func appendedText(hist: History) -> String{
        if(hist.person == "No Person"){
            return "person.slash.fill"
        }else{
            return hist.addedItem ? "arrow.left" : "arrow.right"
        }
    }
    
    func showError(_ message: String){
        errorMessage = message
        showingErrorAlert = true
    }
}
