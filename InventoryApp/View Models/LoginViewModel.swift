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
    
    init(){
        print("Login init")
    }
    
    func register(userEmail: String, userPassword: String) {
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { [self] result, error in
                if let error = error {
                    print("Register Error: \(error.localizedDescription)")
                    errorMessage = "Registration failed: \(error.localizedDescription)"
                    errorShowing = true
                }

                if let result = result {
                    signUpAlert = true
                    username = result.user.email!
                }
            }
        }

    func login(userEmail: String, userPassword: String) {
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { [self] result, error in
            if let error = error {
                print(error)
                errorMessage = "Login failed: \(error.localizedDescription)"
                errorShowing = true
            }

            if let result = result {
                print("User ID: \(result.user.uid)")
                isLoggedIn = true
            }
        }
    }
}
 






