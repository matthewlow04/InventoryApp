//
//  ContentView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView{
            InventoryView().environmentObject(DataManager())
                .tabItem{
                    Label("Inventory", systemImage: "archivebox")
                }
                
            AddItemView().environmentObject(DataManager())
                .tabItem{
                    Label("Add New Item", systemImage: "plus")
                }
            Text("Coming Soon")
                .tabItem{
                    Label("Inventory History", systemImage: "books.vertical")
                }
            Text("Coming Soon")
                .tabItem{
                    Label("Alerts", systemImage: "bell")
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
