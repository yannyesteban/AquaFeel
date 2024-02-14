//
//  TabB.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/1/24.
//

import SwiftUI

struct CC: View {
    @State private var showSettings = false
    
    
    var body: some View {
        Button("View Settings") {
            showSettings = true
        }
        .sheet(isPresented: $showSettings) {
            TabB()
                .presentationDetents([.fraction(0.30), .medium, .large])
                .presentationContentInteraction(.scrolls)
        }
    }
}


struct TabB: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
            Text("\(2)")
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .bold))
            
        }
        
        
    }
}


extension PresentationDetent {
    static let bar = Self.custom(BarDetent.self)
    static let small = Self.height(100)
    static let extraLarge = Self.fraction(0.75)
}


private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}


struct ContentView001: View {
    @State private var showSettings = false
    @State private var selectedDetent = PresentationDetent.bar
    
    
    var body: some View {
        Button("View Settings") {
            showSettings = true
        }
        .sheet(isPresented: $showSettings) {
            TabB()
                .presentationDetents(
                    [.bar, .small, .medium, .large, .extraLarge],
                    selection: $selectedDetent)
        }
    }
}


#Preview {
    ContentView001()
}
