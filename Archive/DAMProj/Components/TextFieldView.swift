//
//  TextFieldView.swift
//  DAMProj
//
//  Created by Mac Mini 3 on 8/11/2024.
//

import SwiftUI

struct TextFieldView: View {
    @Binding var value: String
    @Binding var title: String
    var body: some View {
        TextField(title, text: $value)
            .font(Font.custom("Outfit", size: 14))
            .padding(15)
            .shadow(radius: 5)
            .padding(.bottom, 15)
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldView(value: "", title: "")
    }
}
