//
//  LoginView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-18.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    
    @State private var email = ""
    @State private var password = ""
    
    @AppStorage("uid") var userID: String = ""
    @EnvironmentObject var lvm: LoginViewModel
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        if lvm.isLoggedIn{
            ContentView(userId: userID)
        } else{
            loginView
        }
    }
    
    var loginView: some View{
        ZStack{
            BackgroundView()
            VStack(spacing: 20){
                //Text("Generis Inventory")
                TextField("Email", text: $email)
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                SecureField("Password", text: $password)
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                loginButton
                    .bold()
                signUpButton
                    .bold()
                
            }
            .frame(width:300)
            .foregroundColor(CustomColor.textBlue)
            .sheet(isPresented: $lvm.showingSheet){
                SheetView
            }
            .alert(lvm.errorMessage, isPresented: $lvm.errorShowing, actions: {
                Button("OK", role: .cancel){
                    
                }
            })
        }
       
    }
    
    var SheetView: some View{
        
        VStack(spacing: 20){
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            createAccountButton
        }
        .alert(lvm.errorMessage, isPresented: $lvm.errorShowing, actions: {
            Button("OK", role: .cancel){
                
            }
        })
        .alert("User with email address: \(lvm.username) created", isPresented: $lvm.signUpAlert, actions:{
            Button("OK", role: .cancel){
                lvm.showingSheet = false
            }
        })
       
    }
    
    var loginButton: some View{
        Button("Login"){
            lvm.login(userEmail: email, userPassword: password)
        }
    }
    
    var signUpButton: some View{
        Button("Don't have an account? Sign up."){
            lvm.showingSheet = true
        }
    }
    var createAccountButton: some View{
        Button("Create Account"){
            lvm.register(userEmail: email, userPassword: password)
            
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
