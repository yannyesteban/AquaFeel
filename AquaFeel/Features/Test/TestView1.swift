//
//  TestView1.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 15/5/24.
//


import SwiftUI
import MapKit

struct TestView1: View {
    var body: some View {
        VStack {
            Text("Open Apple Maps")
                .padding()
                .onTapGesture {
                    openAppleMaps()
                }
        }
    }
    
    func openAppleMaps() {
        // Coordenadas de ejemplo
        let startCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let stop1Coordinate = CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179) // Fresno
        let stop2Coordinate = CLLocationCoordinate2D(latitude: 35.3733, longitude: -119.0187) // Bakersfield
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles
        
        // Crear placemarks y map items
        let startPlacemark = MKPlacemark(coordinate: startCoordinate)
        let startItem = MKMapItem(placemark: startPlacemark)
        startItem.name = "Start Location"
        
        let stop1Placemark = MKPlacemark(coordinate: stop1Coordinate)
        let stop1Item = MKMapItem(placemark: stop1Placemark)
        stop1Item.name = "Stop 1"
        
        let stop2Placemark = MKPlacemark(coordinate: stop2Coordinate)
        let stop2Item = MKMapItem(placemark: stop2Placemark)
        stop2Item.name = "Stop 2"
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        destinationItem.name = "Destination Location"
        
        // Crear opciones de lanzamiento
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        // Abrir Apple Maps con múltiples destinos
        MKMapItem.openMaps(with: [startItem, stop1Item, stop2Item, destinationItem], launchOptions: launchOptions)
    }
}

#Preview {
    TestView1()
}
