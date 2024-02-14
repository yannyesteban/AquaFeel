//
//  SplashScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/1/24.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        
        Image("Logo2")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300)
            .foregroundColor(Color.indigo)
            .backgroundStyle(.yellow)
         
        Text("RoadMap")
    }
}

#Preview {
    SplashScreen()
}
