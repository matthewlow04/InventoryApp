//
//  PersonListView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-28.
//

import SwiftUI

struct PersonListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack{
            List(dataManager.people, id: \.self){ person in
                NavigationLink(destination: PersonView(selectedPerson: person)){
                    HStack{
                        Text(person.firstName+" "+person.lastName)
                            .bold()
                    }
                }
                
                
            }
            .toolbar{
          
                NavigationLink(destination: AddPersonView()){
                    Text("Add Person")
                }
            
            }
            .onAppear{
                dataManager.fetchPeopleData()
            }
            .navigationTitle("People")
        }
        
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonListView()
    }
}
