//
//  ItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-14.
//

import SwiftUI
import Charts

struct ItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var ivm = ItemViewModel()
    @State var selectedItem: Item
    @State var isPresentingConfirm = false
    @State var isShowingAlert = false
    @State var isShowingCat = false
    @State var alertMessage = "Item saved"
    @State var editedNotes = ""
    @State var editedLocation = ""
    @State var currentlyEditing = false
    @State var showingPopover = false
    @State var selectedCategory: Item.Category?
    @State var enteredLink: String = ""
    @State var addAmount = ""
    @State var amountAddedTotal = 0
    @State var sliderChangeAmount = 0
    @State var addStock = true
    
    @Environment(\.dismiss) var dismiss

  
    var onItemUpdated: () -> Void
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    Text(selectedItem.name)
                        .font(.largeTitle)
                        .frame(width: 250)
                        .lineLimit(2)
                            
                    Spacer()
                    Image(systemName: selectedItem.isFavourite ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.yellow)
                        .onTapGesture {
                            selectedItem.isFavourite.toggle()
                        }
                        .padding(.leading, -50)
                        .contentTransition(.symbolEffect(.replace))
                }

                Text("\(Int(selectedItem.amountInStock)) in stock / \(selectedItem.amountTotal) in total")
                
                Button(selectedItem.category.rawValue){
                    isShowingCat = true
                    
                }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(ivm.getBackgroundColor(for: selectedItem.category))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                
                Toggle(currentlyEditing ? "Editing..." : "Edit", isOn: $currentlyEditing)
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 10)

                
                Divider()
                    .padding(.top, 10)

                List {
                    Group{
                        Section(header: Text("Change Amount")) {
                            VStack{
                                Slider(value: Binding<Double>(
                                    get: { Double(selectedItem.amountInStock) },
                                    set: { newValue in
                                        selectedItem.amountInStock = Int(newValue)
                                    }
                                ), in: 0...Double(selectedItem.amountTotal), step: 1)
                                TextField("Amount in Stock", text: Binding(
                                    get: { "\(Int(selectedItem.amountInStock))" },
                                    set: { newValue in
                                        if let intValue = Int(newValue), intValue >= 0 && intValue <= selectedItem.amountTotal {
                                            selectedItem.amountInStock = (intValue)
                                        }
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
     
                           
                        }
                        
                        

                        Section(header: Text("Notes")) {
                            
                            if currentlyEditing {
                                TextField("Edit Notes", text: $editedNotes)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                if(selectedItem.notes != ""){
                                    Text(selectedItem.notes)
                                }else{
                                    Text("No Notes")
                                        .italic()
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }

                        Section(header: Text("Stock History")) {
                            HStack {
                                Spacer()
                                chartView
                                Spacer()
                            }
                        }
                        Section(header: Text("People")){
                            VStack{
                                VStack{
                                    HStack{
                                        Text("Name")
                                        Spacer()
                                        VStack{
                                            Text("Amount")
                                            Text("in Stock")
                                        }
                                        
                                    }
                                }
                                ScrollView{
                                    VStack {
                                        ForEach(dataManager.people.sorted(by: { person1, person2 in
                                            guard let item1 = person1.inventory.first(where: { $0.itemID.lowercased() == selectedItem.name.lowercased() }),
                                                  let item2 = person2.inventory.first(where: { $0.itemID.lowercased() == selectedItem.name.lowercased() }) else {
                                                return false
                                            }
                                            return item1.quantity > item2.quantity
                                        }), id: \.self) { person in
                                            if let assignedItem = person.inventory.first(where: { $0.itemID.lowercased() == selectedItem.name.lowercased() }) {
                                                ItemPersonView(person: person, itemID: assignedItem.itemID)
                                            }
                                        }
                                    }
                                    
                                }.frame(height: 200).padding(.bottom, 10)
                                Divider()
                                    .padding(.bottom, 10)
                                
                                HStack{
                                    Text("Total Assigned to People")
                                    Spacer()
                                    Text("\(ivm.getAmountAssignedToPeople(people: dataManager.people, item: selectedItem))")
                                        .foregroundStyle(Color.accentColor)
                                        .bold()
                                        .padding(.horizontal, 5)
                                }
                                    .padding(.bottom, 10)
                                Divider()
                                    .padding(.bottom, 10)
                                
                                HStack{
                                    Text("Total Unassigned to People")
                                    Spacer()
                                    Text("\(selectedItem.amountUnassigned)")
                                        .foregroundStyle(Color.accentColor)
                                        .bold()
                                        .padding(.horizontal, 5)
                                }
             
                            }
                           
                        
                        }
                
                        
                        Section(header: Text("Location")) {
                            VStack(alignment: .leading){
                                VStack{
                                    if currentlyEditing {
                                        TextField("Edit Location", text: $editedLocation)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }else{
                                        if(selectedItem.location != ""){
                                            Text(selectedItem.location)
                                        }else{
                                            Text("No Location")
                                                .italic()
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                }
                                .padding(.bottom, 10)
                                if currentlyEditing{
                                    VStack(spacing: 30){
                                        ScrollView(.horizontal){
                                            HStack{
                                                ForEach(dataManager.locations, id: \.self){ location in
                                                    Button(location){
                                                        editedLocation = location
                                                    }
                                                    .foregroundStyle(Color.accentColor)
                                                }
                                            }
                                            
                                        }
                                        Button {
                                            editedLocation = ""
                                        } label: {
                                               Text("Clear Location")
                                                   .frame(maxWidth: .infinity)
                                                   .frame(height: 44)
                                                   .background(Color.clear)
                                                   .border(Color.accentColor, width: 1)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                
                                
                                   
                                }
                            }
                          
                            
                          
                        }
                        
                    }
                    
                    Section(header: Text("Order Link")){
                        if(selectedItem.link == ""){
                            HStack{
                                TextField("Enter Order Link", text: $enteredLink)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .frame(maxWidth: .infinity)
                                Spacer()
                                Button("Add") {
                                    if(enteredLink.isValidURL){
                                        ivm.makeValidLink(url: &enteredLink)
                                        selectedItem.link = enteredLink
                                        print(selectedItem)
                                        dataManager.addLink(itemName: selectedItem.name, url: selectedItem.link)
                                        enteredLink = ""
                                    }else{
                                        alertMessage = "Invalid URL or unable to open the URL"
                                        isShowingAlert = true
                                    }
                                   
                                }
                                .buttonStyle(BorderlessButtonStyle())
                       
                            }
                          
                        }else{
                            HStack{
                                Text("Order Link")
                                   .foregroundStyle(.blue)
                                   .underline()
                                   .onTapGesture {
                                       ivm.makeValidLink(url: &selectedItem.link)
                                       if let url = URL(string: selectedItem.link), UIApplication.shared.canOpenURL(url) {
                                           UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                       } else {
                                           alertMessage = "Invalid URL or unable to open the URL"
                                           isShowingAlert = true
                                       }
                                   }
                                Spacer()
                                Button("Remove Link"){
                                    selectedItem.link = ""
                                    dataManager.addLink(itemName: selectedItem.name, url: "")
                                }
                                .foregroundStyle(Color.red)
                                .buttonStyle(BorderlessButtonStyle())
                       
                                
                            }
                            
                        }
                    }
                    
                    Section{
                        VStack(alignment: .leading){
                            Text("Date Created: \(formattedDate(date: selectedItem.dateCreated))")
                            Text("Last Updated: \(timeSince(date: selectedItem.dateUpdated))")
                        }
                        .foregroundStyle(Color.gray)
                    }

                    Section {
                        deleteButton
                            .buttonStyle(DeleteButtonStyle())
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                Button("Delete '\(selectedItem.name.lowercased())' from inventory?", role: .destructive) {
                                    dataManager.deleteItem(itemName: selectedItem.name)
                                    alertMessage = "Item deleted"
                                    isShowingAlert = true
                                    dismiss()
                                        }
                            }
                    }
                }
                .scrollContentBackground(.hidden)
                

                    

            }
            .onTapGesture {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let relevantWindow = windowScene.windows.first {
                    relevantWindow.rootViewController?.view.endEditing(true)
                }
            }
            
            VStack{
                HStack{
                    Spacer()
                    Button("x"){
                        addAmount = ""
                        showingPopover = false
                    }
                }
              
               
                TextField("Amount", text: $addAmount)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                
                
                Button("Confirm"){
                    if(addAmount.isEmpty){
                        showingPopover = false
                        addAmount = ""
                        return
                    }
                    
                    guard let addAmt = Int(addAmount) else {
                        showingPopover = false
                        alertMessage = "Invalid input for amount"
                        isShowingAlert = true
                        addAmount = ""
                        return
                    }
                    
                    
                    if(addStock == true){
                        selectedItem.amountInStock  = addAmt + selectedItem.amountInStock
                        selectedItem.amountTotal = addAmt + selectedItem.amountTotal
                        amountAddedTotal = amountAddedTotal + addAmt
                    }else{
                        if(addAmt > selectedItem.amountInStock){
                            showingPopover = false
                            alertMessage = "Can't remove delete more stock than exists"
                            isShowingAlert = true
                            
                        }else{
                            selectedItem.amountInStock  = selectedItem.amountInStock - addAmt
                            selectedItem.amountTotal = selectedItem.amountTotal - addAmt
                            amountAddedTotal = amountAddedTotal - addAmt
                        }
                    }
                    addAmount = ""
                    showingPopover = false
                }
                Spacer()
            }
            .frame(width: showingPopover ? 100 : 0, height: showingPopover ? 100 : 0)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
            )
            .background(Color.white)
            .opacity(showingPopover ? 1 : 0)
            .animation(
                Animation
                    .smooth,
                value: UUID()
            )
        }
        

        .toolbar{
            ToolbarItemGroup{
                Button("Add Stock"){
                    addStock = true
                    showingPopover.toggle()
                }
                Button("Remove Stock"){
                    addStock = false
                    showingPopover.toggle()
                }
                
                Button("Save"){
                    
                    let oldAmount = dataManager.getItemByName(name: selectedItem.name)?.amountInStock
                    if(selectedItem.amountUnassigned - (selectedItem.amountInStock - amountAddedTotal - oldAmount!) < 0){
                        alertMessage = "You can't return assigned items through here"
                        selectedItem.amountInStock = oldAmount! + amountAddedTotal
                        isShowingAlert = true
                        return
                    }
                    alertMessage = "Item Saved"
                    if(amountAddedTotal != 0){
                        
                        dataManager.updateItem(itemName: selectedItem.name, newAmount: Int(selectedItem.amountInStock), itemTotal: selectedItem.amountTotal, itemHistory: selectedItem.amountHistory, isFavourite: selectedItem.isFavourite, notes: (editedNotes != "") ? editedNotes : selectedItem.notes, category: selectedItem.category.rawValue, newStock: true, location: (editedLocation != "") ? editedLocation : selectedItem.location, unassignedAmount: selectedItem.amountUnassigned, calledByAddItem: true, calledByUndo: true)
                        
                        if(amountAddedTotal > 0){
                            //deals with any new item changes
                            dataManager.createHistory(name: selectedItem.name, amount: amountAddedTotal, added: true, id: UUID().uuidString, person: "No Person", newStock: true, deleteStock: false)
                            
                            //deals with any stock amount changes
                            
                            dataManager.createHistory(name: selectedItem.name, amount: abs(selectedItem.amountInStock - amountAddedTotal - oldAmount!), added: selectedItem.amountInStock - amountAddedTotal - oldAmount! > 0, id: UUID().uuidString, person: "No Person", newStock: false, deleteStock: false)
                            
                            let unassigned = selectedItem.amountUnassigned + oldAmount! + amountAddedTotal - selectedItem.amountInStock
                            dataManager.updateUnassigned(itemName: selectedItem.name, unassigned: unassigned)
                        }

                        else{
                            
                            //deals with any deletion changes
                            dataManager.createHistory(name: selectedItem.name, amount: amountAddedTotal, added: false, id: UUID().uuidString, person: "No Person", newStock: false, deleteStock: true)
        
                            //deals with any stock amount changes
                            
                            dataManager.createHistory(name: selectedItem.name, amount: abs(selectedItem.amountInStock - amountAddedTotal - oldAmount!), added: selectedItem.amountInStock - amountAddedTotal - oldAmount! > 0, id: UUID().uuidString, person: "No Person", newStock: false, deleteStock: false)
                            
                            let unassigned = selectedItem.amountUnassigned + oldAmount! + amountAddedTotal - selectedItem.amountInStock
                            dataManager.updateUnassigned(itemName: selectedItem.name, unassigned: unassigned)
                        }
                       
                        
                      

                    }
//                    else if(amountAddedTotal < 0){
//                        dataManager.updateItem(itemName: selectedItem.name, newAmount: Int(selectedItem.amountInStock), itemTotal: selectedItem.amountTotal, itemHistory: selectedItem.amountHistory, isFavourite: selectedItem.isFavourite, notes: (editedNotes != "") ? editedNotes : selectedItem.notes, category: selectedItem.category.rawValue, location: (editedLocation != "") ? editedLocation : selectedItem.location, unassignedAmount: selectedItem.amountUnassigned)
//                    }
                    else{
                        dataManager.updateItem(itemName: selectedItem.name, newAmount: Int(selectedItem.amountInStock), itemTotal: selectedItem.amountTotal, itemHistory: selectedItem.amountHistory, isFavourite: selectedItem.isFavourite, notes: (editedNotes != "") ? editedNotes : selectedItem.notes, category: selectedItem.category.rawValue, location: (editedLocation != "") ? editedLocation : selectedItem.location, unassignedAmount: selectedItem.amountUnassigned)
                        
                    }
                   
                    if(editedLocation != ""){
                        addToLocations()
                    }
                    
                    isShowingAlert = true
                    dataManager.fetchLocations()
                    dismiss()
                }
                
            }
            
            
        }.alert(alertMessage, isPresented: $isShowingAlert, actions: {
            Button("OK", role: .cancel){}
        })
        .sheet(isPresented: $isShowingCat){
            sheetView
        }
        .onAppear{
//            print("Amount: \(selectedItem.amountInStock)")
            dataManager.fetchItems()
        }
        .onDisappear{
            onItemUpdated()
            dismiss()
        }

        
    }
    
    
    var chartView: some View{
        Chart(0..<selectedItem.amountHistory.count, id: \.self){ nr in
                    LineMark(
                        x: .value("X values", nr),
                        y: .value("Y values", selectedItem.amountHistory[nr])
                    )
        }
        .frame(width: 300, height: 100)
        .chartXAxis(.hidden)
        
    }
         
    var deleteButton: some View{
        Button("Delete Item"){
            isPresentingConfirm = true
            
        }
    }
    
    var clearButton: some View{
        Button("Clear"){
            editedLocation = ""
        }
        
    }
    
    var sheetView: some View {
        VStack {
            Text("Select Category")
                .modifier(SheetTitleModifier())

            ForEach(Item.Category.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    
                }) {
                    Text(category.rawValue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ivm.getBackgroundColor(for: category))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Button("Dismiss") {
                isShowingCat = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .onChange(of: selectedCategory) {
            if let selectedCategory = selectedCategory {
                selectedItem.category = selectedCategory
                self.selectedCategory = nil
            }
            isShowingCat = false
        }
    }
    
    func addToLocations(){
        for dataLocation in dataManager.locations{
            if(dataLocation.lowercased() == editedLocation.lowercased()){
                return
            }
        }
        dataManager.addLocation(editedLocation)
    }
}

