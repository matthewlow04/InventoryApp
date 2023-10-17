//
//  Modifiers.swift
//  InventoryApp
//
//  Created by Matthew Low on 2023-10-10.
//

import Foundation
import SwiftUI

struct HeadlineModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(.leading, 15)
            .padding(.top, 5)
    }
}

struct SheetTitleModifier: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(CustomColor.textBlue)
    }
}
