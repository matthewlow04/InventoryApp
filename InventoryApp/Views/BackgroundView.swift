//
//  BackgroundView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-20.
//

import SwiftUI

struct BackgroundView: View {
    var isLogin:Bool
    var body: some View {
        
        VStack{
            if(isLogin){
                Text("Welcome")
                    .foregroundColor(CustomColor.textBlue)
                    .font(.system(size: 40, design: .rounded))
                    .padding(.top, 100)
            }
            else{
                VStack(alignment: .trailing, spacing: 50){
                    
                    Rectangle()
                        .foregroundColor(CustomColor.aquamarine)
                        .frame(width: 200, height: 25)
                        .cornerRadius(20)
                    Rectangle()
                        .foregroundColor(CustomColor.skyBlue)
                        .frame(width: 150, height: 25)
                        .cornerRadius(20)
                    Rectangle()
                        .foregroundColor(CustomColor.lightBlue)
                        .frame(width: 100, height: 25)
                        .cornerRadius(20)
                    Spacer()
                        .frame(maxWidth:.infinity)
                    
                        
              
                }.opacity(0.6)
                    .padding(.top)
                    .frame(maxWidth: .infinity)
               
            }

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
        BackgroundView(isLogin: false)
    }
}
