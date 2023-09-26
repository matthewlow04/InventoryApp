//
//  AlertModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-26.
//

import Foundation

struct Notification: Hashable{
    var alertType: String
    var alertMessage: String
    var severity: String
    var date: Date
    var seen: Bool
    
}

