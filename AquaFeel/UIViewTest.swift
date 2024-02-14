//
//  UIViewTest.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 27/1/24.
//

import SwiftUI



struct TextView: UIViewRepresentable {
    @Binding var value: String
    
    func makeUIView(context: Context) -> UITextField {
        UITextField()
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.placeholder = "Cualquiera"
        uiView.text = value
    }
}
/*
struct UIViewTest: UIViewRepresentable {
    @Binding var value: NSMutableAttributedString
    
    func makeUIView(context: Context) -> some UITextView {
        UITextView()
    }
    
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = value
    }
}

#Preview {
    
    @State var text = NSMutableAttributedString(string : "yanny")
    TextView(value: $text)
}
 */

struct ContentView1: View {
    @State var text = "Cool"
    
    var body: some View {
        TextView(value: $text)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}


#Preview {
    
   
    ContentView1()
}
