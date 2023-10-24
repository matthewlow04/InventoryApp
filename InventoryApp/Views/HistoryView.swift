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
                        print("\(item) FROM HERE")
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
