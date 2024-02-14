//
//  MapScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/1/24.
//

import SwiftUI
import GoogleMaps




struct MapScreen: View {
    @State var mode = false
    @State var path = GMSMutablePath()
    var body: some View {
        ZStack(alignment: .top) {
            /*MapViewControllerBridge(mode: $mode, path: $path)
                .sheet(isPresented: $mode) {
                    PathOptionView()
                    .presentationDetents([.fraction(0.30), .medium, .large])
                    .presentationContentInteraction(.scrolls)
            }*/
        }
    }
}
struct ContentView_Previews22: PreviewProvider {
    static var previews: some View {
        MapScreen()//.edgesIgnoringSafeArea(.all)
    }
}


