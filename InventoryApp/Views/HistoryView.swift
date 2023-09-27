//
//  HistoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack{
            List(dataManager.inventoryHistory, id: \.self){ item in
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text(item.itemName)
                            .bold()
                        Text("\(item.addedItemString(item.addedItem)) \(item.amount)")
                    }
                    Spacer()
                    Text(timeSince(date: item.date))
                        .foregroundColor(.gray)
                        .italic()
                       
                }
                    
                
            }
            .navigationTitle("Inventory History")
            .onAppear{
                dataManager.fetchInventoryHistory()
            }
        }
       
        
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}