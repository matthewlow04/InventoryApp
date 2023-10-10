//
//  FavouritesRowView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-10.
//

import SwiftUI

struct FavouritesRowView: View {
    @ObservedObject var ivm = ItemViewModel()
    @EnvironmentObject var dataManager: DataManager
    var body: some View {
        VStack(alignment: .leading){
            
            Text("Favourites")
                .modifier(HeadlineModifier())
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10){
                    ForEach(dataManager.inventory.filter{$0.isFavourite == true}, id: \.self){ item in
                        NavigationLink(destination: ItemView(selectedItem: item)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getBackgroundColor(for: item.category) ) .listRowSeparatorTint(.clear)
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

#Preview {
    FavouritesRowView()
}
