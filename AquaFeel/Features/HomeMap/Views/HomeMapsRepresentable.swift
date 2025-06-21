//
//  HomeMapsRepresentable.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct HomeMapsRepresentable: UIViewControllerRepresentable {
    @Binding var location: CLLocationCoordinate2D
    var mapTheme: MapTheme
    var mapsCluster = MapsCluster()

    var onInit: ((GMSMapView) -> Void)?
    func makeUIViewController(context: Context) -> HomeMapsViewController {
        let uiViewController = HomeMapsViewController(location: location, mapTheme: mapTheme)

        onInit?(uiViewController.map)

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: HomeMapsViewController, context: Context) {
    }
}

struct Home1: PreviewProvider {
    static var previews: some View {
        MainAppScreenHomeScreenPreview()
    }
}

