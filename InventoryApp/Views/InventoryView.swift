//  InventoryView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-13.
//

import SwiftUI


struct InventoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var lvm: LoginViewModel
    @ObservedObject var ivm = ItemViewModel()
    @State private var searchText = ""
    @State var isCategories = false
    @State var sortOption = 0
    @State var sortDescending = false
    @State var viewAnimation = false

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return dataManager.inventory
        } else {
            return dataManager.inventory
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        VStack {
            NavigationStack {
                if(!$dataManager.hasLoadedItemData.wrappedValue){
                    ProgressView()
                        .navigationTitle("Inventory")
                }
                else if(dataManager.inventory.isEmpty){
                    Text("No items")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                        .navigationTitle("Inventory")
                }else{
                   
                        
                    ScrollView{
                        VStack(alignment: .leading){
                            if(searchText == ""){
                                FavouritesRowView(onItemUpdated: sortArray, isCat: $isCategories)
                                Text("Main Inventory").modifier(HeadlineModifier())
                      
                            }
                            
                            if(isCategories == false){
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(filteredItems, id: \.self) { item in
                                        NavigationLink(destination: ItemView(selectedItem: item, onItemUpdated: sortArray)){ InventoryPageItemView(name: item.name, total: item.amountTotal, stock: item.amountInStock, color: ivm.getStockColor(stock: Double(item.amountInStock), total: Double(item.amountTotal)).opacity(ivm.getOpacity(stock: Double(item.amountInStock), total: Double(item.amountTotal)))) .listRowSeparatorTint(.clear)
                                            
                                        }
                                        .onAppear {
                                            dataManager.currentNavigationView = .itemView
                                        }
                                    }
                                }
                            }else{
                                CategorizedView(onItemUpdated: sortArray, searchText: $searchText)
                                    .padding(.horizontal,10)
                                
                            }
                            
                           
                        }.animation(viewAnimation ? .easeInOut : .none, value: UUID())
                    }
                    .navigationBarTitle("Inventory")
                    .navigationBarTitleDisplayMode(.automatic)
                    .searchable(text: $searchText)
                    .animation(searchText.isEmpty ? .none: .default,value: UUID())
                    .toolbar{
                        ToolbarItem(placement: .topBarTrailing){
                            Button(action: {
                                withAnimation(){
                                    viewAnimation = true
                                    sortDescending.toggle()
                                    sortArray()
                                }completion:{
                                    viewAnimation = false
                                }
                            }) {
                                Image(systemName: sortDescending ? "arrow.down" : "arrow.up")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.accentColor)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing){
                            Menu {
                                Picker("Sorting Options", selection: $sortOption) {
                                    Text("Alphabetical").tag(0)
                                    Text("Date Created").tag(1)
                                    Text("Date Updated").tag(2)
                                    Text("Stock Left").tag(3)
                                    Text("Stock Left Percent").tag(4)
                                }
                                .onChange(of: sortOption) {
                                    sortArray()
                                }
                                
                            }
                            label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing){
                            Button(action: {
                                withAnimation(){
                                    viewAnimation = true
                                    
                                }completion:{
                                    viewAnimation = false
                                }
                            }) {
                                Image(systemName: isCategories ? "tag.fill" : "tag")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.accentColor)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                           
                        }
                        ToolbarItem(placement: .topBarLeading){
                            Button(action: {
                                withAnimation(){
                                    viewAnimation = true
                                    lvm.isLoggedIn = false
                                }completion:{
                                    viewAnimation = false
                                }
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.accentColor)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                    }
                    
                }
                
            }
            .onAppear {
                sortDescending = false
                dataManager.hasLoadedItemData = false
                dataManager.fetchItems()
                dataManager.fetchAlertHistory()
                dataManager.fetchInventoryHistory()
                dataManager.fetchPeopleData()
                dataManager.fetchLocations()
                sortArray()
            }
            .onDisappear{
                if let currentNavigationView = dataManager.currentNavigationView,
                   !(currentNavigationView == .itemView) {
                        sortOption = 0
                    }
            }
            
        }
    }
    
    func sortArray() {
//        print("sort array called, option: \(sortOption)")
        
        switch sortOption {
        case 0:
            dataManager.inventory.sort { sortDescending ? ($0.name > $1.name) : ($0.name < $1.name)  }
        case 1:
            dataManager.inventory.sort { sortDescending ? ($0.dateCreated > $1.dateCreated) : ($0.dateCreated < $1.dateCreated)  }
        case 2:
            dataManager.inventory.sort { sortDescending ? ($0.dateUpdated > $1.dateUpdated) : ($0.dateUpdated < $1.dateUpdated) }
        case 3:
            dataManager.inventory.sort { sortDescending ? ($0.amountInStock > $1.amountInStock) : ($0.amountInStock < $1.amountInStock) }
        case 4:
            dataManager.inventory.sort { item1, item2 in
                let ratio1 = Double(item1.amountInStock) / Double(item1.amountTotal)
                let ratio2 = Double(item2.amountInStock) / Double(item2.amountTotal)
                if(sortDescending){
                    return ratio1 > ratio2
                }
                else{
                    return ratio1 < ratio2
                }
              
            }
        default:
            break
        }
    }
    
   

}

//struct SortView: View{
//    var body: some View{
//        VStack{
//            Text()
//        }
//    }
//}

