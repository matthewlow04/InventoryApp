//
//  InventoryAppApp.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI
import Firebase

@main
struct InventoryAppApp: App {
    @StateObject var dataManager = DataManager()
    @StateObject var lvm = LoginViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(dataManager)
                .environmentObject(lvm)
                .font(Font.system(size: 16, weight: .medium, design: .rounded))
        }
    }
}
