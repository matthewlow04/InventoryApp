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
    @Published var password = ""
    @Published var resetEmail = ""
    @Published var email = ""
    @Published var isLoggedIn = false
    @Published var accountCreated = false
    @Published var showingSheet = false
    @Published var showingPopover = false
    
    
    func register(userEmail: String, userPassword: String) {
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { [self] result, error in
                if let error = error {
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
            if let error = error as NSError?{
                handleAuthError(error)
            }

            if let result = result {
                print("User ID: \(result.user.uid)")
                isLoggedIn = true
            }
        }
    }
    
    func resetPassword(userEmail: String){
        Auth.auth().sendPasswordReset(withEmail: userEmail) { [self] error in
            if let error = error {
                errorMessage = "Error sending password reset email: \(error.localizedDescription)"
                errorShowing = true
            } else {
                errorMessage = "Password reset email sent successfully"
                errorShowing = true
            }
        }
    }
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
   
    
    private func handleAuthError(_ error: NSError) {
        if error.domain == AuthErrorDomain {
            
            print(error.code)
            switch error.code {
            case 17020:
                errorMessage = "Network Error"
            case 17010:
                errorMessage = "Network request failed. Please check your internet connection."
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                errorMessage = "Email is already in use."
            case AuthErrorCode.weakPassword.rawValue:
                errorMessage = "Password is too weak."
            case AuthErrorCode.invalidEmail.rawValue:
                errorMessage = "Invalid email address."
            case AuthErrorCode.userNotFound.rawValue, AuthErrorCode.wrongPassword.rawValue:
                errorMessage = "Invalid email or password."
            case 17008:
                errorMessage = "Invalid user token. Please sign in again."
            default:
                errorMessage = "Authentication failed. Email address is invalid or password is incorrect"
            }
        } else {
            // Handle non-Firebase errors
            errorMessage = "An unknown error occurred."
        }
        
        errorShowing = true
    }
}
 






