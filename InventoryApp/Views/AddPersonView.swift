//
//  AddPersonView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-27.
//

import SwiftUI

struct AddPersonView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var apvm: AddPersonViewModel
    @Environment(\.dismiss) var dismiss

    
    var itemNames: [String]{
        return ["Pick an item"] + dataManager.inventory.map { $0.name }
    }
    var body: some View {
        if(apvm.showingItems){
            PeopleItemView(apvm: apvm)
        }else{
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
                    NavigationLink("Add Items", destination: PeopleItemView(apvm: apvm))
                }

                
                Section{
                    Button("Add new person"){
                        if apvm.checkValid() == true{
                            let personInventory = apvm.getItemsToAdd()
                            dataManager.addPerson(firstName: apvm.firstName, lastName: apvm.lastName, inventory: personInventory)
                            dataManager.fetchPeopleData()
                            dataManager.fetchItems()
                            apvm.alertMessage = "Person added"
                            apvm.showingAlert = true
                            dismiss()
                        }

                        
                    }
                }
            }.alert(apvm.alertMessage, isPresented: $apvm.showingAlert){
                Button("OK", role: .cancel){
                    
                }
            }
        }
        
    }
}

struct PeopleItemView: View{
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var apvm: AddPersonViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        VStack{
            Text("Items: ")
                .bold()
                .font(Font.system(size: 20))
            ScrollView{
                ForEach(apvm.dataManager.inventory.filter{$0.amountInStock > 0}.indices, id: \.self){ index in
                    let item = apvm.dataManager.inventory[index]
                    VStack(alignment: .leading){
                        Text(item.name)
                        HStack{
                            Slider(value: ($apvm.currentAmount[index]), in: 0...Double(item.amountInStock), step:1)
                            Text("\(Int(apvm.currentAmount[index]))/\(item.amountInStock)")
                        }
                        Divider()
                      
                    }
                }
            }
            
            HStack{
                Button("Clear All"){
                    apvm.clearItems()
                }
                .buttonStyle(DeleteButtonStyle())
                Spacer()
                Button("Add Items"){
                    dismiss()
                }
                .buttonStyle(AddButtonStyle())
                
            }
            
          
           
        }
        .padding(20)
    }
    
    
}
