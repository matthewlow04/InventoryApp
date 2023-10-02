//
//  AddPersonView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-27.
//

import SwiftUI

struct AddPersonView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var apvm = AddPersonViewModel()
    var itemNames: [String]{
        return ["Pick an item"] + dataManager.inventory.map { $0.name }
    }
    var body: some View {
        Form{
            Section{
                HStack{
                    Text("First Name:")
                    TextField("First Name", text: $apvm.firstName)
                }
            }
            
            Section{
                HStack{
                    Text("Last Name:")
                    TextField("Last Name", text: $apvm.lastName)
                }
            }
            
            Section{
                HStack{
                    Text("Item Name:")
                    TextField("Item Name", text: $apvm.itemName)
                }
            }
            
//            Section{
//                Picker("Item Name: ", selection: $apvm.selectedItem){
//                    ForEach(itemNames, id: \.self){
//                        Text($0)
//                    }
//                }
//            }
//         
            
            Section{
                Button("Add new person"){
                    let item = AssignedItem(firstName: apvm.firstName, lastName: apvm.lastName, itemID: apvm.itemName, quantity: Int(apvm.quantity)!)
                    dataManager.addPerson(firstName: apvm.firstName, lastName: apvm.lastName, inventory: [item])
                }
            }
        }
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddPersonView()
    }
}
