//
//  PersonView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-28.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var selectedPerson: Person
    @Environment(\.dismiss) var dismiss
    @State var showingSheet = false
    @State var selectedItem = ""
    @State var itemAmount = 0.0
    var itemNames: [String] {
        let selectedPersonInventoryNames = Set(selectedPerson.inventory.map { $0.itemID })

        return ["Pick an item"] + dataManager.inventory
            .filter { $0.amountInStock > 0 && !selectedPersonInventoryNames.contains($0.name) }
            .map { $0.name }
    }

    var body: some View {
       
       VStack{
           ZStack(alignment: .bottomTrailing){
               CircleImage()
               Image(systemName: "plus")
                   .foregroundColor(.white)
                   .frame(width: 50, height: 50)
                   .background(Color.blue)
                   .clipShape(Circle())
                   .overlay(Circle().stroke(Color.white, lineWidth: 2))
                   .offset(x: -10, y: 10)
           }
       }
       VStack(alignment: .leading){
           Text((selectedPerson.firstName+" "+selectedPerson.lastName))
                .font(.title)
           HStack() {
               Text("Insert person title")
               
               Spacer()
               VStack{
                   Text("Insert person info")
               } .font(.subheadline)
           }
     
        }.padding()
            .foregroundColor(CustomColor.textBlue)
        Text("Inventory").foregroundColor(Color.gray)
        ForEach(selectedPerson.inventory.indices, id: \.self) { index in
            let item = selectedPerson.inventory[index]

            HStack {
                Text(item.itemID)
                Spacer()
                MinusButton(action: {
                    if selectedPerson.inventory[index].quantity > 0 {
                        selectedPerson.inventory[index].quantity -= 1
                    }
                    print(selectedPerson.inventory[index].quantity)
                })
                Text("\(item.quantity)")
                AddButton(action: {
                    selectedPerson.inventory[index].quantity += 1
                    print(selectedPerson.inventory[index].quantity)
                })
            }
            
           
        }.padding(.horizontal, 50)
            .toolbar{
                Button("Save"){
                    dataManager.updatePerson(selectedPerson: selectedPerson)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingSheet){
                SheetView
            }
        Button("Add New Item"){
            showingSheet = true
        }
            
         
    }
    var SheetView: some View{
        VStack{
            Text("Assign Item To Person")
            Picker("Pick an item: ", selection: $selectedItem) {
                ForEach(itemNames, id: \.self) {
                    Text($0)
                }
            }
            .onChange(of: selectedItem) { _ in
                itemAmount = 0
            }

           
            if (selectedItem != ""){
                Slider(value: $itemAmount, in: 0...Double(dataManager.getItemByName(name: selectedItem)!.amountInStock), step:1)
                Text("\(Int(itemAmount)) / \(dataManager.getItemByName(name: selectedItem)!.amountInStock)")
            }
           
            
            Button("Assign Item"){
                
                itemAmount = 0
            }
        }.padding(.horizontal, 50)
      
    
    }
    
   
    
        
    struct CircleImage: View {
//        var picture: String
        var body: some View {
              Image(systemName: "person")
                .resizable()
                .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)
                         .clipShape(Circle())
                         .overlay(Circle().stroke(Color.white, lineWidth: 2))
                         .shadow(radius: 10)
        }
    }
    
    struct MinusButton: View {
        var action: () -> Void
        
        var body: some View {
            Button(action: {
                action()
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .frame(width: 50, height: 50)
            }
        }
    }

    struct AddButton: View {
        var action: () -> Void
        
        var body: some View {
            Button(action: {
                action()
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .frame(width: 50, height: 50)
            }
        }
    }
    
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(selectedPerson: Person(firstName: "Matthew", lastName: "Low", inventory: []))
    }
}
