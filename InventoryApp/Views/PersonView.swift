//
//  PersonView.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-28.
//

import SwiftUI

struct PersonView: View {
    var selectedPerson: Person
    var body: some View {
       
       VStack{
           ZStack(alignment: .bottomTrailing){
               CircleImage()
               Image(systemName: "plus")
                   .foregroundColor(.white)
                   .frame(width: 50, height: 50)
                   .background(Color.blue)
                   .clipShape(Circle())
                   .overlay(Circle().stroke(Color.white, lineWidth: 2))
                   .offset(x: -10, y: 10)
           }
       }
       VStack(alignment: .leading){
           Text((selectedPerson.firstName+" "+selectedPerson.lastName))
                .font(.title)
           HStack() {
               Text("Insert person title")
               
               Spacer()
               VStack{
                   Text("Insert person info")
               } .font(.subheadline)
           }
     
        }.padding()
            .foregroundColor(CustomColor.textBlue)
               
    }
        
    struct CircleImage: View {
//        var picture: String
        var body: some View {
              Image(systemName: "person")
                .resizable()
                .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)
                         .clipShape(Circle())
                         .overlay(Circle().stroke(Color.white, lineWidth: 2))
                         .shadow(radius: 10)
        }
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(selectedPerson: Person(firstName: "Matthew", lastName: "Low", inventory: []))
    }
}
