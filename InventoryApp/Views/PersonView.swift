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
    @State var showingSheetAlert = false
    @State var showingStockAlert = false
    @State var showingAlert = false
    @State var selectedItem = ""
    @State var itemAmount = 0.0
    @State var tapImage = false
    @State var alertMessage = ""
    @State var isPresentingConfirm = false
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
                   .offset(y: tapImage ? -50 : 0)
                   .scaleEffect(tapImage ? 1.5 : 1.0)
                   .onTapGesture {
                       withAnimation(.spring(response:0.5, dampingFraction: 0.8, blendDuration: 0.4)){
                           tapImage.toggle()
                       }
                   }
               Image(systemName: "plus")
                   .foregroundColor(.white)
                   .frame(width: 50, height: 50)
                   .background(Color.blue)
                   .clipShape(Circle())
                   .overlay(Circle().stroke(Color.white, lineWidth: 2))
                   .offset(x: -10, y: 10)
                   .scaleEffect(tapImage ? 0 : 1.0)
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
     
        }
       .alert("This person has all possible unique items", isPresented: $showingAlert, actions: {
           Button("OK", role: .cancel){}
       })
       .alert("There is no more of that item left in stock", isPresented: $showingStockAlert, actions: {
           Button("OK", role: .cancel){}
       })
       .padding()
            .foregroundColor(CustomColor.textBlue)
            .toolbar{
                Button("Save"){
                    dataManager.updatePerson(selectedPerson: selectedPerson)
                    dataManager.saveItemChangesPerson(items: &selectedPerson.inventory, person: selectedPerson)
                    dataManager.fetchPeopleData()

                    dismiss()
                }
            }
            .sheet(isPresented: $showingSheet){
                SheetView
            }
          
        ScrollView{
            Text("Inventory").foregroundColor(Color.gray)
            ForEach(selectedPerson.inventory.indices, id: \.self) { index in
                let item = selectedPerson.inventory[index]

                HStack {
                    Text(item.itemID)
                    Spacer()
                    MinusButton(action: {
                        if selectedPerson.inventory[index].quantity > 0 {
                            selectedPerson.inventory[index].quantity -= 1
                            selectedPerson.inventory[index].currentDifference -= 1
                        }
                       
                        print(selectedPerson.inventory[index].quantity)
                    })
                    Text("\(item.quantity)")
                    AddButton(action: {
                        let item = dataManager.getItemByName(name: selectedPerson.inventory[index].itemID)
                        
                        if(selectedPerson.inventory[index].currentDifference >= item!.amountInStock){
                            showingStockAlert = true
                        }else{
                            selectedPerson.inventory[index].quantity += 1
                            selectedPerson.inventory[index].currentDifference += 1
                            print(selectedPerson.inventory[index].quantity)
                        }
                      
                    })
                }
                
               
            }.padding(.horizontal, 50)
            
        }
        HStack{
            addItemButton
                .buttonStyle(AddButtonStyle())
            Spacer()
            deleteButton
                .buttonStyle(DeleteButtonStyle())
                .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm){
                    Button("Delete \(selectedPerson.firstName) \(selectedPerson.lastName)?", role: .destructive){
                        
                        dataManager.deletePerson(selectedPerson: selectedPerson)
                        dismiss()
                    }
                }
        }
        .padding(30)
        
            
        
        
         
    }
    
    var SheetView: some View{
        VStack{
            Text("Assign Item To Person")
            Picker("Pick an item: ", selection: $selectedItem) {
                ForEach(itemNames, id: \.self) {
                    Text($0)
                }
            }
            .onChange(of: selectedItem) {
                itemAmount = 0
            }

           
            if (selectedItem != ""){
                if(dataManager.getItemByName(name: selectedItem)?.amountInStock != 0){
                    Slider(value: $itemAmount, in: 0...Double(dataManager.getItemByName(name: selectedItem)?.amountInStock ?? 1), step:1)
                }
             
                Text("\(Int(itemAmount)) / \(dataManager.getItemByName(name: selectedItem)?.amountInStock ?? 0)")
            }
            
            HStack{
                assignItemButton
                    .buttonStyle(AddButtonStyle())
                
            }
           
           
        }
        .padding(.horizontal, 50)
        .alert(alertMessage, isPresented: $showingSheetAlert, actions: {
            Button("OK", role: .cancel){
                print(alertMessage)
                print("\(selectedItem) assigned to \(selectedPerson.firstName + " "+selectedPerson.lastName)")
                if(alertMessage == ("\(selectedItem) assigned to \(selectedPerson.firstName + " "+selectedPerson.lastName)")){
                    showingSheet = false
                    selectedItem = ""
                    itemAmount = 0
                    dataManager.fetchPeopleData()
                  
                }
            }
        })
        
        
      
        
        
    }
    
    var addItemButton: some View{
        Button("Add New Item"){
            print(selectedPerson.inventory.count)
            print(dataManager.inventory.filter{$0.amountInStock>0}.count)

            if(itemNames.count != 1){
                showingSheet = true
            }
            else{
                showingAlert = true
            }
            
        }

    }
    
    var deleteButton: some View{
        Button("Delete Person"){
            isPresentingConfirm = true
        }
    }
    
    
   
    var assignItemButton: some View{
        Button("Assign Item"){
            if(selectedItem != ""){
                if(itemAmount > 0){
                    dataManager.addItemToPerson(person: &selectedPerson, itemID: selectedItem, quantity: Int(itemAmount))
                    print(selectedItem)
                    alertMessage = "\(selectedItem) assigned to \(selectedPerson.firstName + " "+selectedPerson.lastName)"
                    showingSheetAlert = true
                    
                    
                }
                else{
                    alertMessage = "You must select an amount"
                    showingSheetAlert = true
                }
                
            }else{
                alertMessage = "You must pick an item"
                showingSheetAlert = true
             
                
            }
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
   
    
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(selectedPerson: Person(firstName: "Matthew", lastName: "Low", inventory: []))
    }
}
