//
//  PersonListView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-28.
//

import SwiftUI

struct PersonListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var searchText = ""
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return dataManager.people
        } else {
            return dataManager.people
                .filter {
                    $0.firstName.lowercased().contains(searchText.lowercased()) ||
                    $0.lastName.lowercased().contains(searchText.lowercased()) ||
                    ($0.firstName + " " + $0.lastName).lowercased().contains(searchText.lowercased())
                }
        }
    }
    
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
        List(filteredPeople, id: \.self){ person in
            NavigationLink(destination: PersonView(selectedPerson: person)){
                HStack{
                    VStack{
                        Text(person.firstName+" "+person.lastName)
                            .bold()
                        Text("# of Items: \(person.inventory.count)")
                            .italic()
                            .opacity(0.5)
                    }
                    Spacer()
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
               
            }
            
            
        }
        .toolbar{
            NavigationLink(destination: AddPersonView(apvm: AddPersonViewModel(dataManager: dataManager))){
                Text("Add Person")
            }
        
        }
        .searchable(text: $searchText)
        
        .navigationTitle("People")
    }
    
}

