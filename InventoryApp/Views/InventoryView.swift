//  InventoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI


struct InventoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    var filteredItems: [Item] {
//        print("filteredItems called")
//        print(dataManager.inventory)
        if searchText.isEmpty {
            return dataManager.inventory
        } else {
            return dataManager.inventory
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            NavigationStack {
                List(filteredItems, id: \.self) { item in
                    NavigationLink(destination: ItemView(selectedItem: item)) {
                        HStack {
                            Text(item.name)
                                .bold()
                            Spacer()
                            Text("\(item.amountInStock)/\(item.amountTotal)")
                        }
                    }
                }
                .navigationTitle("Inventory")
                .searchable(text: $searchText)
            }
            .onAppear {
                dataManager.fetchItems()
                dataManager.fetchAlertHistory()
            }
        }
    }
   
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
