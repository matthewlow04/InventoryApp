//
//  InventoryPageItemView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-03.
//
import Charts
import SwiftUI

struct InventoryPageItemView: View {
    
    var slices: [(Double, Color)]
    var name: String
    var total: Int
    var stock: Int

    var body: some View {
        ZStack{
            
            
            Canvas { context, size in
                let total = slices.reduce(0) { $0 + $1.0 }
                context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
                var pieContext = context
                pieContext.rotate(by: .degrees(-90))
                let radius = min(size.width, size.height) * 0.48
                var startAngle = Angle.zero
                for (value, color) in slices {
                    let angle = Angle(degrees: 360 * (value / total))
                    let endAngle = startAngle + angle
                    let path = Path { p in
                        p.move(to: .zero)
                        p.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                        p.closeSubpath()
                    }
                    pieContext.fill(path, with: .color(color))

                    startAngle = endAngle
                }
                
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 150, height:150)
            
            Circle()
                .foregroundColor(Color.white)
                .frame(width: 100)
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
