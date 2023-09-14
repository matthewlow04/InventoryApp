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
                    Button("Add Item"){
                        if(avm.name != ""){
                            if(dataManager.checkIfExists(name: avm.name)){
                                dataManager.addItem(itemName: avm.name, itemNotes: avm.notes, itemTotal: avm.numberInStock)
                                dataManager.fetchItems()
                                alertMessage = "Item added"
                                showingAlert = true
                            }
                            else{
                                alertMessage = "Item with name '\(avm.name)' already exists!"
                                showingAlert = true
                            }
                               
                           
                        }
                        else{
                            alertMessage = "You must enter a name"
                            showingAlert = true
                        }
                        
                        avm.clearFields()
                    }
                    .alert(alertMessage, isPresented: $showingAlert){
                        Button("OK", role: .cancel){}
                    }
                }
            }.navigationTitle("Add Items")
        }
        
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
       
        AddItemView()
    }
}
