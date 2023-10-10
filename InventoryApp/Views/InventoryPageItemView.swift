//
//  InventoryPageItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-03.
//
import Charts
import SwiftUI

struct InventoryPageItemView: View {
    
    var name: String
    var total: Int
    var stock: Int

    var body: some View {
        ZStack{

            Chart{
                SectorMark(angle: .value("In Stock", stock), innerRadius: .ratio(0.6))
                    .foregroundStyle(CustomColor.lightBlue)
                SectorMark(angle: .value("In Use", total-stock), innerRadius: .ratio(0.6))
                    .foregroundStyle(Color.gray)
            }
            .frame(width: 150, height: 150)
            VStack {
                Text(name)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 100)
                Text("\(stock)/\(total)")
            }
            .bold()
            .foregroundColor(Color.black)
            
        }    
     
    }
}




//struct InventoryPageItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        InventoryPageItemView(slices: [(2,.orange),(3,.gray)])
//    }
//}
