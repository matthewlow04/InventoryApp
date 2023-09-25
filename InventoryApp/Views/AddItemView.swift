//
//  AddItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var avm = AddItemViewModel()
    @State var showingAlert = false
    @State var alertMessage = "Item added"
    @State var duplicateAlert = false
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    HStack{
                        Text("Name: ")
                        TextField("Name", text: $avm.name)
                    }
                }
                Section{
                    HStack{
                        Text("Notes: ")
                        TextField("Add custom notes", text: $avm.notes)
                    }
                }
                
                Section{
                    HStack{
                        Text("Amount: ")
                        TextField("Number of items", text: $avm.numberInStock)
                    }
                }
                
                Section{
                    Picker("Category: ", selection: $avm.selectedCategory, content: {
                        ForEach(avm.categories, id: \.self){
                            Text($0)
                        }
                    })
                }
                
                Section{
                    Button("Add Item"){
                        checkErrors()
                       
                    }
                    .alert(alertMessage, isPresented: $showingAlert){
                        Button("OK", role: .cancel){
                            avm.clearFields()
                        }
                    }
                    .alert(isPresented:$duplicateAlert) {
                                Alert(
                                    title: Text("This item already exists"),
                                    message: Text("Do you want to add to the existing inventory?"),
                                    primaryButton: .default(Text("Yes")) {
                                        print(avm.name)
                                        if let item = dataManager.getItemByName(name: avm.name) {
                                            print("Found item: \(item.name)")
                                            let newItemStock = item.amountInStock + (Int(avm.numberInStock) ?? 0)
                                            let newItemTotal = item.amountTotal + (Int(avm.numberInStock) ?? 0)
                                            dataManager.updateItem(itemName: item.name, itemStock: newItemStock, itemTotal: newItemTotal, itemHistory: item.amountHistory)
                                            alertMessage = "\(avm.numberInStock) were added"
                                            showingAlert = true
                                            avm.clearFields()
                                            
                                        } else {
                                            print("Item not found")
                                            avm.clearFields()
                                        }

                                       
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                }
            }.navigationTitle("Add Items")
        }
        
    }
    
    func checkErrors(){
        if(avm.name != ""){
            if(Int(avm.numberInStock) ?? 0 > 0){
                if(dataManager.checkIfExists(name: avm.name)){
                    dataManager.addItem(itemName: avm.name, itemNotes: avm.notes, itemAmount: avm.numberInStock, category: avm.selectedCategory)
                    dataManager.fetchItems()
                    alertMessage = "Item added"
                    showingAlert = true
                }
                else{
                    duplicateAlert = true
                 
                    
                }
            }
            else{
                alertMessage = "Amount must be a positive number"
                showingAlert = true
            }
            
               
           
        }
        else{
            alertMessage = "You must enter a name"
            showingAlert = true
        }
        
        
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
       
        AddItemView()
    }
}
