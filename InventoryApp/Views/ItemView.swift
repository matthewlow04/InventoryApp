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
    var selectedItem: Item
    @State private var amountInStock: Double
    @State var isPresentingConfirm = false
    @State var isShowingAlert = false
    @Environment(\.dismiss) var dismiss
        
    init(selectedItem: Item) {
        self.selectedItem = selectedItem
        _amountInStock = State(initialValue: Double(selectedItem.amountInStock))
    }
    
    
    var body: some View {
        VStack{
            Text(selectedItem.name)
                .font(.largeTitle)
           
            Text("\(Int(amountInStock)) in stock / \(selectedItem.amountTotal) in total")
            
            Form{
                Section{
                    Slider(value: $amountInStock, in: 0...Double(selectedItem.amountTotal), step:1)
                    Text("\(Int(amountInStock))")
                        
                }header: {
                    Text("Change Amount")
                }
                
                Section{
                    Text(selectedItem.notes)
                }header: {
                    Text("Notes")
                }
                
                Section(header: Text("Stock History")) {
                    chartView
                }
                
                Section{
                    deleteButton
                        .buttonStyle(DeleteButtonStyle())
                        .confirmationDialog("Are you sure?",
                             isPresented: $isPresentingConfirm) {
                            Button("Delete '\(selectedItem.name.lowercased())' from inventory?", role: .destructive) {
                                 dataManager.deleteItem(itemName: selectedItem.name)
                                dismiss()
                             }
                        }
                }
                
                
            }.scrollContentBackground(.hidden)
            
           
           
            
        
            

        }.toolbar{
            Button("Save"){
                dataManager.updateItem(itemName: selectedItem.name, itemStock: Int(amountInStock), itemHistory: selectedItem.amountHistory)
                isShowingAlert = true
                dismiss()
            }
        }.alert("Item Saved", isPresented: $isShowingAlert, actions: {
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
        ItemView(selectedItem: Item(name: "Pencil", notes: "This is a pencil", amountTotal: 0, amountInStock: 0, category: "Stationary", amountHistory: [10]))
    }
}
