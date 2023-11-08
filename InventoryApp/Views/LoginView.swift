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
   
    @EnvironmentObject var lvm: LoginViewModel
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        if lvm.isLoggedIn{
            ContentView()
        } else{
            loginView
                .ignoresSafeArea(.keyboard)
        }
    }
    
    var loginView: some View{
        ZStack{
            BackgroundView(isLogin: true)
            VStack(spacing: 20){
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
                    .padding()
                    .background(CustomColor.aquamarine)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
        .onTapGesture {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let relevantWindow = windowScene.windows.first {
                relevantWindow.rootViewController?.view.endEditing(true)
            }
        }

       
    }
    
    var SheetView: some View {
        ZStack {
            BackgroundView(isLogin: false)
            VStack(spacing: 20) {
            
                Image("generis-logo-color")
                    .padding(.bottom,-50)
                  
                TextField("Email", text: $email)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                
                SecureField("Password", text: $password)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                
                createAccountButton
                    .padding()
                    .background(CustomColor.aquamarine)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.all, 20)
            .alert(lvm.errorMessage, isPresented: $lvm.errorShowing, actions: {
                Button("OK", role: .cancel) {}
            })
            .alert("User with email address: \(lvm.username) created", isPresented: $lvm.signUpAlert, actions: {
                Button("OK", role: .cancel) {
                    lvm.showingSheet = false
                }
            })
            .onTapGesture {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let relevantWindow = windowScene.windows.first {
                    relevantWindow.rootViewController?.view.endEditing(true)
                }
            }

            
        }.ignoresSafeArea(.keyboard)
    }

    
    var loginButton: some View{
        Button("Login"){
            withAnimation(.bouncy){
                lvm.login(userEmail: email, userPassword: password)
            }
          
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
