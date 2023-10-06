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
            .alert("The upload symbol means that the items are coming from the person, the download symbol means the items are going to that person", isPresented: $helpAlertShowing){
                Button("OK", role: .cancel){}
            }
            .navigationTitle("Inventory History")
            .navigationBarItems(trailing: Button(action: {
                           helpAlertShowing = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        })
            .onAppear{
                dataManager.fetchInventoryHistory()
            }
        }      
    }
    
    func appendedText(hist: History) -> String{
        if(hist.person == "No Person"){
            return ""
        }else{
            return hist.addedItem ? "icloud.and.arrow.up" : "icloud.and.arrow.down"
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
