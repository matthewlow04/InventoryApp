//
//  HistoryModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-25.
//

import Foundation

struct History: Hashable, Identifiable{
    var id = UUID()
    var itemName: String
    var date: Date
    var addedItem: Bool
    var amount: Int
    var person: String
    
    func addedItemString(_ addedItem: Bool) -> String{
        return addedItem ? "+":"-"
    }
}


