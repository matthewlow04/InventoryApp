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
        case .office: return Color.red
        case .tech: return Color.green
        case .stationairy: return Color.orange
        case .entertainment: return Color.purple
        case .other: return Color.yellow
        case .select: return Color.white
        }
    }
    
    func getStockColor(stock: Double, total: Double) -> Color{

        let percent = stock/total
        if(percent > 0.67){
            return Color.green
        }else if(percent > 0.34){
            return Color.yellow
        }else{
            return Color.red
        }
    }
    
    func getOpacity(stock: Double, total: Double) -> Double{
        let percent = (stock/total)*100
        if(percent == 100 || (65 < percent && percent < 67 ) || (32 < percent && percent < 34) || (98 < percent && percent < 100 )){
            return 1
        }
        let opacity = Int(percent) % 33
        return (Double(opacity)/33.0)
    }
    
    func getAmountAssignedToPeople(people: [Person], item: Item) -> Int{
        var total = 0
        for person in people{
            if let itemAmount = person.inventory.first(where: {$0.itemID.lowercased() == item.name.lowercased()}){
                let increment = itemAmount.quantity
                total = increment + total
            }
        }
        return total
    }
    
    func makeValidLink( url: inout String){
        if(!url.contains("http")){
            url = "https://" + url
        }
    }
    
}
 
