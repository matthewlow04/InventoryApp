//
//  AddPersonViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-27.
//

import Foundation

class AddPersonViewModel: ObservableObject{
    
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var quantity = ""
    @Published var itemName = ""
    @Published var showingAlert = false
    @Published var alertMessage = "Item added"
    @Published var selectedItem = ""
    
    func clearFields(){
        firstName = ""
        lastName = ""
        quantity = ""
    }
    
}
