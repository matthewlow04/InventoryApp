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
        if searchText.isEmpty {
            return dataManager.inventory
        } else {
            return dataManager.inventory
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        VStack {
            NavigationStack {
                if(!$dataManager.hasLoadedItemData.wrappedValue){
                    ProgressView()
                        .navigationTitle("Inventory")
                }
                else if(dataManager.inventory.isEmpty){
                    Text("No items")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                        .navigationTitle("Inventory")
                }else{
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems, id: \.self) { item in
                                NavigationLink(destination: ItemView(selectedItem: item)){ InventoryPageItemView(slices: [(Double(item.amountInStock), CustomColor.lightBlue), (Double(item.amountTotal-item.amountInStock), Color.gray.opacity(0.4))], name: item.name, total: item.amountTotal, stock: item.amountInStock) .listRowSeparatorTint(.clear)
                                }
                            }
                        }
                        .navigationTitle("Inventory")
                        .searchable(text: $searchText)
                        .animation(searchText.isEmpty ? .none: .default)
                    }
                }
                
            }
            .onAppear {
                dataManager.hasLoadedItemData = false
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
