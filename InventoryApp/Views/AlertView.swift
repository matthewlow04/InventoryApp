//
//  AlertView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-26.
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack{
            NavigationStack {
                        List {
                            ForEach(dataManager.alerts, id: \.id) { item in
                                AlertRow(alert: item)
                            }
                            .onDelete { indexSet in
                                    for index in indexSet {
                                        let alertToDelete = dataManager.alerts[index]
                                        deleteAlert(alertID: alertToDelete.id, alert: alertToDelete)
                                    }
                                }
                        }
                        .navigationTitle("Alerts")
                        .onAppear {
//                            dataManager.fetchAlertHistory()
                        }
                    }
        }
    }
    
    func deleteAlert(alertID: String, alert: Notification) {
        if let index = dataManager.alerts.firstIndex(where: { $0.id == alert.id }) {
            dataManager.alerts.remove(at: index)
            dataManager.deleteAlert(alertID: alertID)
                   
        }
    }
 
}

struct AlertRow: View {
    var alert: Notification

    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 10){
                Text(alert.alertType)
                    .bold()
                Text("\(alert.alertMessage)")
                
                Text(timeSince(date: alert.date))
                    .foregroundColor(.gray)
                    .italic()
            }
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(getAlertColour(severity: alert.severity))
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
