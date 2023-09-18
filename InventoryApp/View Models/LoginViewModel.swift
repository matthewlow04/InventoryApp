//
//  LoginViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-18.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject{
    @Published var errorMessage = ""
    @Published var errorShowing = false
    @Published var signUpAlert = false
    @Published var username = ""
    @Published var isLoggedIn = false
    @Published var accountCreated = false
    @Published var showingSheet = false
    
    func register(userEmail: String, userPassword: String){
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { [self] result, error in
            if error != nil{
                errorMessage = error!.localizedDescription
                errorShowing = true
            }
            if let result = result{
                signUpAlert = true
                username = result.user.email!
            }
        }
    }
    func login(userEmail: String, userPassword: String){
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { [self] result, error in
            if error != nil{
                errorMessage = error!.localizedDescription
                errorShowing = true
            }
            if let result = result {
                print(result.user.uid)
                isLoggedIn = true
            }
            
        }
    }
}
