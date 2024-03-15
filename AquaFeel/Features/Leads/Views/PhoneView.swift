//
//  PhoneView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/3/24.
//

import SwiftUI

struct PhoneView: View {
    let label: String
    @Binding var text: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                TextField(label, text: $text)
                
                if text != ""{
                    Button(action: {
                        action()
                    }) {
                        Image(systemName: "phone")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
            }
        }
    }
    
    init(_ label: String, text: Binding<String>, action: @escaping () -> Void) {
        self.label = label
        self._text = text
        self.action = action
    }
}

#Preview {
    PhoneView("telefono", text: .constant("yanny")){
        print("my phone")
    }
}
