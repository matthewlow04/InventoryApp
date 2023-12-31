//
//  LoginView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-18.
//

import SwiftUI
import Firebase

struct LoginView: View {    
    

   
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
                TextField("Email", text: $lvm.email)
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                SecureField("Password", text: $lvm.password)
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
                resetPasswordButton
                    .bold()
            }

            .frame(width:300)
            .foregroundColor(CustomColor.textBlue)
           
            .sheet(isPresented: $lvm.showingSheet){
                SheetView
            }
            
            VStack{
                HStack{
                    Spacer()
                    Button("x"){
                        lvm.showingPopover = false
                    }
                }
              
               
                TextField("Email", text: $lvm.resetEmail)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                
                
                Button("Reset Password") {
                    if lvm.resetEmail.isEmpty {
                        lvm.showingPopover = false
                        return
                    }

                    if !lvm.isValidEmail(email: lvm.resetEmail) {
                        lvm.errorMessage = "Invalid email"
                        lvm.errorShowing = true
                        lvm.showingPopover = false
                        return
                    }
                    
                    lvm.resetPassword(userEmail: lvm.resetEmail)
                    lvm.showingPopover = false
                }
                Spacer()
            }
            .frame(width: lvm.showingPopover ? 250 : 0, height: lvm.showingPopover ? 100 : 0)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
            )
            .background(Color.white)
            .opacity(lvm.showingPopover ? 1 : 0)
            .animation(
                Animation
                    .smooth,
                value: UUID()
            )
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
                  
                TextField("Email", text: $lvm.email)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(CustomColor.aquamarine)
                    .padding(.bottom)
                
                SecureField("Password", text: $lvm.password)
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
                lvm.login(userEmail: lvm.email, userPassword: lvm.password)
            }
          
        }
    }
    
    var signUpButton: some View{
        Button("Don't have an account? Sign up."){
            lvm.showingSheet = true
        }
    }
    
    var resetPasswordButton: some View{
        Button("Forgot Password"){
            lvm.showingPopover = true
        }
    }
    
    var createAccountButton: some View{
        Button("Create Account"){
            lvm.register(userEmail: lvm.email, userPassword: lvm.password)
            
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
