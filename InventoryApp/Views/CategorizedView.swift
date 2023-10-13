//
//  CategorizedView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-10.
//

import SwiftUI

struct CategorizedView: View {
    @EnvironmentObject var dataManager: DataManager
    var onItemUpdated: () -> Void
    let categories = Item.Category.allCases.filter 
    { $0 != .select }
    @Binding var searchText: String
    var body: some View {
        ForEach(categories, id: \.self) { category in
            CategoryRowView(onItemUpdated: onItemUpdated, searchText: $searchText, category: category)
        }
    }
}

struct CategoryRowView: View{
    
    var onItemUpdated: () -> Void
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var ivm = ItemViewModel()
    @Binding var searchText: String
    var category: Item.Category
    var body: some View{
        Text(category.rawValue)
            .modifier(HeadlineModifier())
        if(listOfItems(category: category).isEmpty){
          
            Text("No Items")
                .italic()
                .padding(.vertical, 25)
                .frame(maxWidth: .infinity, alignment: .center)
            
           
        }else{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(listOfItems(category: category), id: \.self){ item in
                        NavigationLink(destination: ItemView(selectedItem: item, onItemUpdated: onItemUpdated)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getStockColor(stock: Double(item.amountInStock), total: Double(item.amountTotal)).opacity(ivm.getOpacity(stock: Double(item.amountInStock), total: Double(item.amountTotal))) ) .listRowSeparatorTint(.clear)
                        }
                    }
                }
            }
       
            
            
        }
    }
    
    func listOfItems(category: Item.Category) -> [Item]{
        var list = dataManager.inventory.filter{$0.category == category}
        if (searchText != ""){
            list = list.filter{$0.name.lowercased().contains(searchText.lowercased())}
        }
         
        return list
    }
                    
                   
}
                    

