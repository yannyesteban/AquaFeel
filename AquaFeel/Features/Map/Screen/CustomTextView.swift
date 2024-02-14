//
//  CustomTextView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/1/24.
//

import SwiftUI
import GoogleMaps


struct CustomTextView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> GMSMapView {
        
        
        
        let mapView = GMSMapView()
        mapView.camera = GMSCameraPosition(latitude: 37.36, longitude: -122.0
                                           , zoom: 20.0
        )
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        
        mapView.settings.myLocationButton = true
        
        //mapView.delegate = context.coordinator
        //map.tag = 12474737
        //print(map.tag)
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        //uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        
        
#if DEBUG
        
        GMSServices.provideAPIKey("")
#endif
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomTextView
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
    }
}

struct ContentView7: View {
    var body: some View {
        CustomTextView(text: "Hello, SwiftUI!")
           
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView7()
    }
}

#Preview {
    ContentView7()
}
