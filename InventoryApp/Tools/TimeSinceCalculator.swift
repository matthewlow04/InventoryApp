//
//  TimeSinceCalculator.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-25.
//

import Foundation

func timeSince(date: Date) -> String {
    let minutes = Int(-date.timeIntervalSinceNow)/60
    let hours = minutes/60
    let days = hours/24
    
    if minutes < 120 {
        return "\(minutes) minutes ago"
    }
    else if minutes >= 120 && hours < 48 {
        return "\(hours) hours ago"
    }
    else{
        return "\(days) days ago"
    }
}

func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy" // Customize the date format as needed
    return dateFormatter.string(from: date)
}
