//
//  InventoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var dataManager: DataManager
    var body: some View {
        NavigationStack{
            List(dataManager.inventory, id: \.self){ item in
                NavigationLink(destination: ItemView(selectedItem: item)) {
                    HStack {
                        Text(item.name)
                            .bold()
                        Spacer()
                        Text("\(item.amountInStock)/\(item.amountTotal)")
                    }
                }
            }.navigationTitle("Inventory")
        }
        .onAppear{
            dataManager.fetchItems()
        }
        
    }
    
    
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
