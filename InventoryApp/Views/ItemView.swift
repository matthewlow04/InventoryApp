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
//    @State private var amountInStock: Double
    @State var isPresentingConfirm = false
    @State var isShowingAlert = false
    @State var alertMessage = "Item saved"
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(selectedItem.name)
                    .font(.largeTitle)
                Spacer()
                Image(systemName: selectedItem.isFavourite ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(Color.yellow)
                    .onTapGesture {
                        selectedItem.isFavourite.toggle()
                    }
                    .padding(.leading, -50)
            }

            Text("\(Int(selectedItem.amountInStock)) in stock / \(selectedItem.amountTotal) in total")
            
            Text(selectedItem.category.rawValue)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(ivm.getBackgroundColor(for: selectedItem.category))
                .cornerRadius(20)
                .foregroundColor(.white)
            
            Divider()
                .padding(.top, 10)

            List {
                Group{
                    Section(header: Text("Change amount")) {
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

                    Section(header: Text("Notes")) {
                        Text(selectedItem.notes)
                    }

                    Section(header: Text("Stock History")) {
                        HStack {
                            Spacer()
                            chartView
                            Spacer()
                        }
                    }
                    
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
            UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
        }
        .toolbar{
            Button("Save"){
                dataManager.updateItem(itemName: selectedItem.name, newAmount: Int(selectedItem.amountInStock), itemTotal: selectedItem.amountTotal, itemHistory: selectedItem.amountHistory, isFavourite: selectedItem.isFavourite)
                isShowingAlert = true
                dismiss()
            }
        }.alert(alertMessage, isPresented: $isShowingAlert, actions: {
            Button("OK", role: .cancel){}
        })
        
        
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
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(selectedItem: Item(name: "Pencil", notes: "This is a pencil", amountTotal: 20, amountInStock: 10, category: Item.Category.stationairy, amountHistory: [10], isFavourite: true))
    }
}
