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
            if(!$dataManager.hasLoadedPeopleData.wrappedValue ){
                ProgressView()
                    .navigationTitle("People")
            }
            else if(dataManager.people.isEmpty){
               NoPeople
            }else{
               LoadedView
            }
           
   
        }
        .onAppear{
            dataManager.hasLoadedPeopleData = false
            dataManager.fetchPeopleData()
        }
        .toolbar{
            NavigationLink(destination: AddPersonView(apvm: AddPersonViewModel(dataManager: dataManager))){
                Text("Add Person")
            }
        
        }
        
    }
    
    var NoPeople: some View{
        Text("No people")
            .font(.title)
            .foregroundColor(.secondary)
            .padding()
            .navigationTitle("People")
        .toolbar{
            NavigationLink(destination: AddPersonView(apvm: AddPersonViewModel(dataManager: dataManager))){
                Text("Add Person")
            }
        
        }
    }
    
    var LoadedView: some View{
        List(dataManager.people, id: \.self){ person in
            NavigationLink(destination: PersonView(selectedPerson: person)){
                HStack{
                    Text(person.firstName+" "+person.lastName)
                        .bold()
                }
            }
            
            
        }
        .toolbar{
            NavigationLink(destination: AddPersonView(apvm: AddPersonViewModel(dataManager: dataManager))){
                Text("Add Person")
            }
        
        }
        .navigationTitle("People")
    }
    
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonListView()
    }
}
