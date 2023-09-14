//
//  ItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-14.
//

import SwiftUI

struct ItemView: View {
    var selectedItem: Item
    @State private var amountInStock: Double
        
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
            }

        }.toolbar{
            Button("Save"){
                
            }
        }
        
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(selectedItem: Item(name: "Pencil", notes: "This is a pencil", amountTotal: 0, amountInStock: 0))
    }
}
