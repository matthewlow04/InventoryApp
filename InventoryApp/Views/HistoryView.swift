//
//  HistoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-25.
//

import SwiftUI

struct HistoryView: View {
    @State var helpAlertShowing = false
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack{
            if(!$dataManager.hasLoadedHistoryData.wrappedValue){
                ProgressView()
                    .navigationTitle("Inventory History")
            }
            else if(dataManager.inventoryHistory.isEmpty){
                Text("No inventory history")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
                    .navigationTitle("Inventory History")
            }else{
                List(dataManager.inventoryHistory, id: \.self){ item in
                    HStack{
                        VStack(alignment: .leading, spacing: 10){
                            Text(item.itemName)
                                .bold()
                            Text("\(item.addedItemString(item.addedItem)) \(item.amount)")
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            HStack{
                                Image(systemName: appendedText(hist: item))
                                Text(item.person)
                            }
                            
                            Text(timeSince(date: item.date))
                                .foregroundColor(.gray)
                                .italic()
                        }

                       
                    }
                }
                .alert("The arrow right means the person is receiving items from inventory, the arrow left means the items are going back to inventory", isPresented: $helpAlertShowing){
                    Button("OK", role: .cancel){}
                }
                .navigationTitle("Inventory History")
                .navigationBarItems(trailing: Button(action: {
                               helpAlertShowing = true
                            }) {
                                Image(systemName: "questionmark.circle")
                            })
            }
            
            
        }
        .onAppear{
            dataManager.hasLoadedHistoryData = false
            dataManager.fetchInventoryHistory()
        }
    }
    
    func appendedText(hist: History) -> String{
        if(hist.person == "No Person"){
            return "person.slash.fill"
        }else{
            return hist.addedItem ? "arrow.left" : "arrow.right"
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
