//
//  ItemViewModel.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-03.
//

import Foundation
import SwiftUI

class ItemViewModel: ObservableObject{
    
    func getBackgroundColor(for category: Item.Category) -> Color {
        switch category {
        case .office: return Color.blue
        case .tech: return Color.green
        case .stationairy: return Color.orange
        case .entertainment: return Color.purple
        case .other: return Color.gray
        }
    }
}
 
