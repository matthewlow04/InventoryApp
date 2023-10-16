//
//  AddItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject var avm: AddItemViewModel

    init(dataManager: DataManager) {
        _avm = StateObject(wrappedValue: AddItemViewModel(dataManager: dataManager))
    }
    
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
                        avm.checkErrors()
                    }
                }
            }
            .navigationTitle("Add Items")
            .alert(avm.alertMessage, isPresented: $avm.showingAlert){
                Button("OK", role: .cancel){
                    if (avm.alertMessage != "You must pick a category"){
                        avm.clearFields()
                    }
                }
            }
            .foregroundStyle(CustomColor.textBlue)
            .alert(isPresented:$avm.duplicateAlert) {
                Alert(
                    title: Text("This item already exists"),
                    message: Text("Do you want to add to the existing inventory?"),
                    primaryButton: .default(Text("Yes")) {
                        print(avm.name)
                        if let item = dataManager.getItemByName(name: avm.name) {
                            print("Found item: \(item.name)")
                            let newItemStock = item.amountInStock + (Int(avm.numberInStock) ?? 0)
                            let newItemTotal = item.amountTotal + (Int(avm.numberInStock) ?? 0)
                            dataManager.updateItem(itemName: item.name, newAmount: newItemStock, itemTotal: newItemTotal, itemHistory: item.amountHistory, isFavourite: item.isFavourite)
                            avm.alertMessage = "\(avm.numberInStock) were added"
                            avm.showingAlert = true
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
        
    }
    
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(dataManager: DataManager())
    }
}
