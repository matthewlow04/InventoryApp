//
//  PersonModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-27.
//

import Foundation

struct Person:Hashable{
    var firstName: String
    var lastName: String
    var title: String
    var inventory: [AssignedItem]
    var isFavourite: Bool
}

struct AssignedItem:Hashable{
    var firstName: String
    var lastName: String
    var itemID: String
    var quantity: Int
    var currentDifference = 0
}

