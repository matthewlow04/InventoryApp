import SwiftUI


struct InventoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""

    var body: some View {
        VStack {
            NavigationView {
                List(filteredItems, id: \.self) { item in
                    NavigationLink(destination: ItemView(selectedItem: item)) {
                        HStack {
                            Text(item.name)
                                .bold()
                            Spacer()
                            Text("\(item.amountInStock)/\(item.amountTotal)")
                        }
                    }
                }
                .navigationTitle("Inventory")
                .searchable(text: $searchText)
            }
            .onAppear {
                dataManager.fetchItems()
            }
        }
    }

    var filteredItems: [Item] {
//        print("filteredItems called")
//        print(dataManager.inventory)
        if searchText.isEmpty {
            return dataManager.inventory
        } else {
            return dataManager.inventory
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
