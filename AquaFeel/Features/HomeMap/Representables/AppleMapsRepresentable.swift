//
//  AppleMapsRepresentable.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 7/5/24.
//


import SwiftUI
import MapKit
import GoogleMaps





struct AppleMapsRepresentable: UIViewControllerRepresentable  {
    @Binding var location: CLLocationCoordinate2D
    
    
    
    var onInit: ((MapsProvider) -> Void)?
    func makeUIViewController(context: Context) -> AppleMapsViewController {
        let uiViewController = AppleMapsViewController(location: location)
        
        onInit?(uiViewController.getProvider())
        
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: AppleMapsViewController, context: Context) {
    }
}
