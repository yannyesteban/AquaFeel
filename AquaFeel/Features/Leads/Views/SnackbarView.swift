//
//  SnackbarView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/2/24.
//

import SwiftUI

struct SnackbarView: View {
    let message: String
    @Binding var isShowing: Bool
    @State private var opacity = 0.0
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack {
                Spacer()
                Text("\(opacity)")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                    .opacity(isShowing ? 1 : opacity )
                    //.animation(.easeInOut(duration: 0.3))
                    .animation(Animation.easeInOut(duration: 5.0), value: opacity)
            }
        }
        .padding(.horizontal)
        .onChange(of: isShowing){ x in
            print(x, x, x)
            if x {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                   
                    withAnimation {
                        isShowing = false
                    }
                }
            }
            
        }
        
    }
}
