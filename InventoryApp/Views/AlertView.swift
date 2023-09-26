//
//  AlertView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-26.
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var dataManager: DataManager
    
    let alertArray = [Notification(alertType: "Low Stock", alertMessage: "Your mouse stock is at 1/4", severity: "Medium", date: Date.now, seen: false)]
    
    var body: some View {
        NavigationStack{
            List(alertArray, id: \.self){ item in
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text(item.alertType)
                            .bold()
                        Text("\(item.alertMessage)")
                        
                        
                        Text(timeSince(date: item.date))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    Spacer()
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                        .foregroundColor(getAlertColour(severity: item.severity))
                }
                    
                
            }
            .navigationTitle("Alerts")
            .onAppear{
              
            }
        }
    }
    
    func getAlertColour(severity: String) -> Color{
        let severityLevel = severity.lowercased()
        if severityLevel == "high"{
            return Color.red
        }
        else if severityLevel == "medium"{
            return Color.yellow
        }
        else{
            return Color.green
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
