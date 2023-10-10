//
//  CategorizedView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-10.
//

import SwiftUI

struct CategorizedView: View {
    @EnvironmentObject var dataManager: DataManager
    
    let categories = Item.Category.allCases.filter { $0 != .select }
    
    var body: some View {
        ForEach(categories, id: \.self) { category in
            CategoryRowView(category: category)
        }
    }
}

struct CategoryRowView: View{
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var ivm = ItemViewModel()
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
            ScrollView(.horizontal){
                HStack{
                    ForEach(listOfItems(category: category), id: \.self){ item in
                        NavigationLink(destination: ItemView(selectedItem: item)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getStockColor(stock: Double(item.amountInStock), total: Double(item.amountTotal)).opacity(ivm.getOpacity(stock: Double(item.amountInStock), total: Double(item.amountTotal))) ) .listRowSeparatorTint(.clear)
                        }
                    }
                }
            }
       
            
            
        }
    }
    
    func listOfItems(category: Item.Category) -> [Item]{
        let list = dataManager.inventory.filter{$0.category == category}
        return list
    }
                    
                   
}
                    

#Preview {
    CategorizedView()
}
