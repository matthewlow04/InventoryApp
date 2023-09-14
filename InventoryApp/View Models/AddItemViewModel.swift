//
//  AddItemViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import Foundation

class AddItemViewModel: ObservableObject{
    
    @Published var name = ""
    @Published var notes = ""
    @Published var numberInStock = ""
    @Published var showingAlert = false
    @Published var alertMessage = "Item added"
    
    func clearFields(){
        name = ""
        notes = ""
        numberInStock = ""
    }
    
}
