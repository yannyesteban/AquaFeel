//
//  TabC.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/1/24.
//

import SwiftUI

struct TabC: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(.red)
            Text("\(3)")
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .bold))
            
        }
        
        
    }
}

#Preview {
    TabC()
}
