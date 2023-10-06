//
//  ItemModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import Foundation

struct Item: Hashable{
    var name: String
    var notes: String
    var amountTotal: Int
    var amountInStock: Int
    var category: Category
    enum Category: String, CaseIterable, Codable{
        case select = "Select"
        case office = "Office"
        case tech = "Tech"
        case stationairy = "Stationairies"
        case entertainment = "Entertainment"
        case other = "Other"
    }  
    var amountHistory: [Int]

   
}
