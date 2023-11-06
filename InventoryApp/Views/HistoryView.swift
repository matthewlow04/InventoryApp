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
    @State var selectedHistoryItem: History?
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
            if(!$dataManager.hasLoadedHistoryData.wrappedValue){
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
//                        print("\(item) FROM HERE")
                    } label: {
                        HStack{
                            VStack(alignment: .leading, spacing: 10){
                                Text(item.itemName)
                                    .bold()
                                Text("\(item.addedItemString(item.addedItem)) \(item.amount)")
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
                    .confirmationDialog("Actions", isPresented: $showingActionSheet) {
                        Button("Undo Change"){
                            
                            let itemInstance = dataManager.getItemByName(name: item.itemName)
                            
                            
                           
//                            let itemInstance = dataManager.getItemByName(name: item.itemName)
//                            
//                            if(selectedHistoryItem!.person != "No Person"){
//                                guard var person = dataManager.getPersonByName(name: selectedHistoryItem!.person) else{
//                                    return
//                                }
//                                guard let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) else {
//                                    print("This person no longer has this item in their inventory")
//                                    return
//                                }
//                            }else{
//                                if(selectedHistoryItem!.addedItem && !selectedHistoryItem!.newStock){
//                                    
//                                }
//                                else if(!selectedHistoryItem!.addedItem){
//                                    
//                                }
//                                dataManager.deleteHistory(id: item.id)
//                                dataManager.updateItem(itemName: selectedHistoryItem!.itemName, newAmount: selectedHistoryItem!.addedItem ? itemInstance!.amountInStock - selectedHistoryItem!.amount : itemInstance!.amountInStock + selectedHistoryItem!.amount, itemTotal: selectedHistoryItem!.newStock ? itemInstance!.amountTotal - selectedHistoryItem!.amount : itemInstance!.amountTotal, itemHistory: itemInstance?.amountHistory ?? [], isFavourite: itemInstance!.isFavourite, notes: itemInstance!.notes, category: (itemInstance?.category.rawValue)!, updateHistory: false)
//                                dataManager.hasLoadedHistoryData = false
//                            }
//                            
                            
                           

                        }
                        Button("Duplicate Change"){
                            
                            let itemInstance = dataManager.getItemByName(name: selectedHistoryItem!.itemName)
                            
                            print(itemInstance!.name)
                            print(selectedHistoryItem!.amount)
                            
                            //Person Exists
                            if(selectedHistoryItem!.person != "No Person"){
                                guard var person = dataManager.getPersonByName(name: selectedHistoryItem!.person) else{
                                    print("This person no longer exists")
                                    return
                                }
                                let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) ?? -1
                                print(index)
                                
                                //if an item is taken away check if the person has enough inventory to perform this action
                                
                                //item subtracted from inventory to person
                                if(!selectedHistoryItem!.addedItem){
                                   
                                    //if it wasn't newly added
                                    if(!selectedHistoryItem!.newStock){
                                        
                                        
                                        //check if there's enough inventory to give to person
                                        if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
                                            print("Not enough in inventory to duplicate this change")
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
                                                               location: itemInstance!.location
                                                               
                                        )
                                        
                                        //update person inventory
                                        if(index != -1){
                                            person.inventory[index].quantity =  person.inventory[index].quantity + selectedHistoryItem!.amount
                                            dataManager.updatePerson(selectedPerson: person)
                                        }
                                        else{
                                        
                                            dataManager.addItemToPerson(person: &person, itemID: selectedHistoryItem!.itemName, quantity: selectedHistoryItem!.amount)
                                        }
                    
                                       
                                        
                                    }
                                    //if that was a newly added item(can't happen as of right now)
                                    
                                    else{
                                        print("Error!")
                                    }
                                        
                                    
                                   
                                    
                                }
                                //item added to inventory from person
                                else{
                                    
                                    //check if person has in inventory
                                    if(index == -1){
                                        print("Person no longer has this item")
                                        return
                                        
                                    }
                                    
                                    // check if person has enough inventory
                                    if(person.inventory[index].quantity - selectedHistoryItem!.amount < 0){
                                        print("Person doesn't have enough of this item to duplicate this change")
                                        return
                                    }
                                    
                                  
                                    
                                    if(itemInstance!.amountInStock + selectedHistoryItem!.amount > itemInstance!.amountTotal){
                                        print("You are returning more items to inventory than exist in circulation")
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
                                                           location: itemInstance!.location)
                                    
                                    //update person inventory
                                    
                                    person.inventory[index].quantity =  person.inventory[index].quantity - selectedHistoryItem!.amount
                                    dataManager.updatePerson(selectedPerson: person)
                                  
                                }
                                
                            }
                            //Person does not exist
                            else{
                                //item is subtracted from inventory
                                if(!selectedHistoryItem!.addedItem){
                                    
                                    //if not enough inventory return
                                    if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
                                        print("Not enough in inventory to duplicate this change")
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
                                            print("You are returning more items to inventory than exist in circulation")
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
                                                               location: itemInstance!.location,
                                                               calledByAddItem: true
                                        )
                                    }
                                }
                            }
                          
//                            let itemInstance = dataManager.getItemByName(name: selectedHistoryItem!.itemName)
//                            if(selectedHistoryItem!.person != "No Person"){
//                                guard var person = dataManager.getPersonByName(name: selectedHistoryItem!.person) else{
//                                    return
//                                }
//                                guard let index = dataManager.getIndexInPersonInventory(name: selectedHistoryItem!.itemName, person: person) else {
//                                    print("This person no longer has this item in their inventory")
//                                    return
//                                }
//                                
//                                if(selectedHistoryItem!.addedItem && !selectedHistoryItem!.newStock){
//                                    if(person.inventory[index].quantity - selectedHistoryItem!.amount < 0){
//                                        print("The selected person doesn't have enough in their inventory to perform this action")
//                                        return
//                                    }
//                                    if((itemInstance!.amountInStock + selectedHistoryItem!.amount) > itemInstance!.amountTotal){
//                                        print("You can't add more items into stock than exists in total")
//                                    }
//                                    else{
//                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName, newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount, itemTotal: selectedHistoryItem!.newStock ? itemInstance!.amountTotal + selectedHistoryItem!.amount : itemInstance!.amountTotal, itemHistory: itemInstance?.amountHistory ?? [], person: selectedHistoryItem?.person, isFavourite: itemInstance!.isFavourite, notes: itemInstance!.notes, category: (itemInstance?.category.rawValue)!)
//                                        dataManager.hasLoadedHistoryData = false
//                                        
//                                      
//                                        person.inventory[index].quantity = (person.inventory[index].quantity - selectedHistoryItem!.amount)
//                                        dataManager.updatePerson(selectedPerson: person)
//                                        dataManager.saveItemChangesPerson(items: &person.inventory, person: person)
//                                    }
//                                }else if(!selectedHistoryItem!.addedItem){
//                                    
//                                    if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
//                                        print("You don't have enough in stock to perform this action")
//                                        
//                                    }
//                                    else{
//                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName, newAmount: itemInstance!.amountInStock - item.amount, itemTotal: selectedHistoryItem!.newStock ? itemInstance!.amountTotal + selectedHistoryItem!.amount : itemInstance!.amountTotal, itemHistory: itemInstance?.amountHistory ?? [], person: selectedHistoryItem!.person, isFavourite: itemInstance!.isFavourite, notes: itemInstance!.notes, category: (itemInstance?.category.rawValue)!)
//                                        dataManager.hasLoadedHistoryData = false
//                                        
//                                        person.inventory[index].quantity = (person.inventory[index].quantity + selectedHistoryItem!.amount )
//                                        dataManager.updatePerson(selectedPerson: person)
//                                        dataManager.saveItemChangesPerson(items: &person.inventory, person: person)
//                                    }
//                                    
//                                }
//                               
//                            }
//                            else{
//                                if(selectedHistoryItem!.addedItem && !selectedHistoryItem!.newStock){
//                                    if((itemInstance!.amountInStock + selectedHistoryItem!.amount) > itemInstance!.amountTotal){
//                                        print("You can't add more items into stock than exists in total")
//                                    }
//                                    else{
//                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName, newAmount: itemInstance!.amountInStock + selectedHistoryItem!.amount, itemTotal: selectedHistoryItem!.newStock ? itemInstance!.amountTotal + selectedHistoryItem!.amount : itemInstance!.amountTotal, itemHistory: itemInstance?.amountHistory ?? [], person: selectedHistoryItem?.person, isFavourite: itemInstance!.isFavourite, notes: itemInstance!.notes, category: (itemInstance?.category.rawValue)!)
//                                        dataManager.hasLoadedHistoryData = false
//                                    }
//                                }else if(!selectedHistoryItem!.addedItem){
//                                    if(itemInstance!.amountInStock - selectedHistoryItem!.amount < 0){
//                                        print("You don't have enough in stock to perform this action")
//                                    }
//                                    else{
//                                        dataManager.updateItem(itemName: selectedHistoryItem!.itemName, newAmount: itemInstance!.amountInStock - item.amount, itemTotal: selectedHistoryItem!.newStock ? itemInstance!.amountTotal + selectedHistoryItem!.amount : itemInstance!.amountTotal, itemHistory: itemInstance?.amountHistory ?? [], person: selectedHistoryItem!.person, isFavourite: itemInstance!.isFavourite, notes: itemInstance!.notes, category: (itemInstance?.category.rawValue)!)
//                                        dataManager.hasLoadedHistoryData = false
//                                    }
//                                    
//                                }
//         
//                            }
//                            
                           
                        }
                    }
                    .foregroundStyle(Color.black)

                   
                   
                }
                .alert("The arrow right means the person is receiving items from inventory, the arrow left means the items are going back to inventory", isPresented: $helpAlertShowing){
                    Button("OK", role: .cancel){}
                }
                .searchable(text: $searchText)
                .navigationTitle("Inventory History")
                .navigationBarItems(trailing: Button(action: {
                               helpAlertShowing = true
                            }) {
                                Image(systemName: "questionmark.circle")
                            })
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
}
