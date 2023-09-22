////
////  InventoryViewModel.swift
////  InventoryApp
////
////  Created by Matthew Low on 2023-09-13.
////
//import Foundation
//
//class InventoryViewModel: ObservableObject {
//    var dataManager = DataManager()
//
//    @Published var searchText = "" {
//        didSet {
//            // The filteredResults computed property will automatically update
//        }
//    }
//
//    // Change the updateFilteredResults function to a computed property
//    @Published var filteredResults: [Item] {
//        if searchText.isEmpty {
//            return dataManager.inventory // Show all items when searchText is empty
//        } else {
//            return dataManager.inventory
//                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
//        }
//    }
//
//    init() {
//        dataManager.fetchItems()
//        // No need to call updateFilteredResults here
//    }
//}
//
