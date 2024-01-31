//
//  MapIconView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/1/24.
//

import SwiftUI

struct MapIconView2: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 50, height: 50)
                .shadow(color: .gray, radius: 3, x: 0, y: 2) // Ajusta los valores según sea necesario
            
            Image(systemName: "dot.radiowaves.up.forward")
                .font(.system(size: 30))
                .foregroundColor(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 1) // Ajusta los valores según sea necesario
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    MapIconView2()
}
