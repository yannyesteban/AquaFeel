//
//  TabView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/1/24.
//

import SwiftUI

struct MyTab: View {
    var body: some View {
        TabView {
            TabA()
                .tabItem{
                    Image(systemName: "house")
                    Text("Home")
                }
            TabB().tabItem{
                Image(systemName: "person")
                Text("Account")
            }
            
            TabC().tabItem{
                Image(systemName: "cart")
                Text("Cart")
            }
        }
    }
}

#Preview {
    MyTab()
}
