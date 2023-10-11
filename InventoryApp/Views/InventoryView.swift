//  InventoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI


struct InventoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var ivm = ItemViewModel()
    @State private var searchText = ""
    @State var isCategories = false
    @State var viewAnimation = false
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
                        VStack(alignment: .leading){
                            if(searchText == ""){
                                FavouritesRowView(isCat: $isCategories)
                                Text("Main Inventory").modifier(HeadlineModifier())
                            }
                            
                            if(isCategories == false){
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(filteredItems, id: \.self) { item in
                                        NavigationLink(destination: ItemView(selectedItem: item)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getStockColor(stock: Double(item.amountInStock), total: Double(item.amountTotal)).opacity(ivm.getOpacity(stock: Double(item.amountInStock), total: Double(item.amountTotal)))) .listRowSeparatorTint(.clear)
                                        }
                                    }
                                }
                            }else{
                                CategorizedView(searchText: $searchText)
                                
                            }
                            
                           
                        }.animation(viewAnimation ? .easeInOut : .none)
                    }
                    .navigationTitle("Inventory")
                    .searchable(text: $searchText)
                    .animation(searchText.isEmpty ? .none: .default)
                    .toolbar{
                        Button(isCategories ? "Uncategorizied":"Categorized"){
                            withAnimation(){
                                viewAnimation = true
                                isCategories.toggle()
                            }completion:{
                                viewAnimation = false
                            }
                        }
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
