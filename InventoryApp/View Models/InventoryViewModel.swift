//
//  InventoryViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//
import Foundation

//save for later
class InventoryViewModel: ObservableObject {
    var dataManager = DataManager()
    
    @Published var searchText = "" {
        didSet {
            updateFilteredResults()
        }
    }
    
    @Published var filteredResults: [Item] = []
    
    init() {
        dataManager.fetchItems()
        updateFilteredResults() // Initialize filteredResults with all items
    }
    
    func updateFilteredResults() {
        if searchText.isEmpty {
            filteredResults = dataManager.inventory // Show all items when searchText is empty
        } else {
            filteredResults = dataManager.inventory
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

