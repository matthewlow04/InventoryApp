//
//  ItemPersonView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-25.
//

import SwiftUI

struct ItemPersonView: View {
    @EnvironmentObject var dataManager: DataManager
    var person: Person
    var itemID: String
    var body: some View {
        VStack{
            Divider()
            HStack(){
                VStack(alignment: .leading){
                    Text(person.firstName)
                    Text(person.lastName)
                }
                Spacer()
                Text("\(person.inventory[dataManager.getIndexInPersonInventory(name: itemID, person: person)!].quantity)")
                    .foregroundStyle(Color.accentColor)
                    .bold()
            }.frame(height: 75)
        }
    }
    
}
