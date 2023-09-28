//
//  BackgroundView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-20.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        
        VStack{
            Image("generis-logo-color")
            VStack(alignment: .leading, spacing: 50){
                
                Spacer()
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .foregroundColor(CustomColor.lightBlue)
                    .frame(width: 100, height: 25)
                    .cornerRadius(20)
                Rectangle()
                    .foregroundColor(CustomColor.skyBlue)
                    .frame(width: 150, height: 25)
                    .cornerRadius(20)
                Rectangle()
                    .foregroundColor(CustomColor.aquamarine)
                    .frame(width: 200, height: 25)
                    .cornerRadius(20)
                    
          
            }.opacity(0.6)
        }
       
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
