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
            AddItemView(dataManager: dataManager)
                .environmentObject(dataManager)
                .tabItem{
                    Label("Add New Item", systemImage: "plus")
                }
            PersonListView()
                .tabItem{
                    Label("People", systemImage: "person")
                }
            HistoryView()
                .tabItem{
                    Label("Inventory History", systemImage: "books.vertical")
                }
            AlertView()
                .tabItem{
                    Label("Alerts", systemImage: "bell")
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
