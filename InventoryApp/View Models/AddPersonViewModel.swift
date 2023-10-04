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
    @Published var alertMessage = ""
    @Published var selectedItem = ""
    
    func clearFields(){
        firstName = ""
        lastName = ""
        quantity = ""
    }
    
    func checkValid() -> Bool{
        if (firstName != "" && lastName != ""){
            return true
        }
        else{
            if(firstName == ""){
                alertMessage = "You must enter a first name"
                showingAlert = true
            }else{
                alertMessage = "You must enter a last name"
                showingAlert = true
            }
            return false
        }
    }
    
}
