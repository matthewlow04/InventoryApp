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
    var amountTotal = 0
    var amountInStock = 0
}
