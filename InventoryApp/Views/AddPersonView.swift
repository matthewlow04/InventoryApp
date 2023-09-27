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
            
            Section{
                HStack{
                    Text("Quantity:")
                    TextField("Quantity", text: $apvm.quantity)
                }
            }
            
            Section{
                Button("Add new person"){
                    let item = AssignedItem(firstName: apvm.firstName, lastName: apvm.lastName, itemID: apvm.itemName, quantity: Int(apvm.quantity)!)
                    dataManager.addPerson(firstName: apvm.firstName, lastName: apvm.lastName, inventory: [item])
                }
            }
            
            Section{
                Button("Check fetch"){
                    dataManager.fetchPeopleData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        print(dataManager.people)
                    }
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
