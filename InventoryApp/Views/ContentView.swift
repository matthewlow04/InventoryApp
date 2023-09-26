//
//  ContentView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    var userId: String

    var body: some View {
        TabView{
            
            
            
            InventoryView()
                .tabItem{
                    Label("Inventory", systemImage: "archivebox")
                }
            
            
            AddItemView()
                .tabItem{
                    Label("Add New Item", systemImage: "plus")
                }
            
            HistoryView()
                .tabItem{
                    Label("Inventory History", systemImage: "books.vertical")
                }
            AlertView()
                .tabItem{
                    Label("Alerts", systemImage: "bell")
                }
           
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userId: "")
    }
}
