//
//  FavouritesRowView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-10.
//

import SwiftUI

struct FavouritesRowView: View {
    var onItemUpdated: () -> Void
    @ObservedObject var ivm = ItemViewModel()
    @EnvironmentObject var dataManager: DataManager
    @Binding var isCat: Bool
    var body: some View {
        VStack(alignment: .leading){
            
            Text("Favourites")
                .modifier(HeadlineModifier())
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10){
                    ForEach(dataManager.inventory.filter{$0.isFavourite == true}, id: \.self){ item in
                        NavigationLink(destination: ItemView(selectedItem: item, onItemUpdated: onItemUpdated)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getStockColor(stock: Double(item.amountInStock), total: Double(item.amountTotal)).opacity(ivm.getOpacity(stock: Double(item.amountInStock), total: Double(item.amountTotal))) ) .listRowSeparatorTint(.clear)
                        }
                        .onAppear {
                            dataManager.currentNavigationView = .itemView
                        
                        }
                    }
                }
               
            }
        }
        
    }
}

struct FavouritesCell: View{
    var name: String
    var total: Int
    var stock: Int
    var color: Color
    @EnvironmentObject var dataManager: DataManager
    var body: some View{
        InventoryPageItemView(name: name, total: total, stock: stock, color: color)
    }
}

//#Preview {
//    FavouritesRowView(isCat: )
//}
