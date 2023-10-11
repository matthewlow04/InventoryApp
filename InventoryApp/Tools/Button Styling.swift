//
//  Button Styling.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-09-15.
//

import SwiftUI

struct DeleteButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.white)
            .font(.callout)
            .background(configuration.isPressed ? Color.red.opacity(0.4) : Color.red)
            .clipShape(Capsule(style: .circular))
    }
}

struct AddButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.white)
            .font(.callout)
            .background(configuration.isPressed ? Color.green.opacity(0.4) : Color.green)
            .clipShape(Capsule(style: .circular))
    }
}
