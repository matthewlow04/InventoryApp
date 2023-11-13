//
//  ContentView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    

    var body: some View {
        TabView{
            InventoryView()
                .tabItem{
                    Label("Inventory", systemImage: "archivebox")
                }
                .onAppear {
                    dataManager.currentNavigationView = .inventory
                }
            AddItemView(dataManager: dataManager)
                .environmentObject(dataManager)
                .tabItem{
                    Label("Add New Item", systemImage: "plus")
                }
                .onAppear {
                    dataManager.currentNavigationView = .other
                }
            PersonListView()
                .tabItem{
                    Label("People", systemImage: "person")
                }
                .onAppear {
                    dataManager.currentNavigationView = .other
                }
            HistoryView()
                .tabItem{
                    Label("Inventory History", systemImage: "books.vertical")
                }
                .onAppear {
                    dataManager.currentNavigationView = .other
                }
            AlertView()
                .tabItem{
                    Label("Alerts", systemImage: "bell")
                }
                .onAppear {
                    dataManager.currentNavigationView = .other
                }
                .badge(dataManager.alerts.count)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
