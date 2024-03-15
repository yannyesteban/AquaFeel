//
//  ContentView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import SwiftUI
import GoogleMaps
import GoogleMapsUtils


let kClusterItemCount = 100
let kCameraLatitude = 37.36
let kCameraLongitude = -122.0

struct MapView: UIViewRepresentable {
    @EnvironmentObject var lead:LeadViewModel
    let marker : GMSMarker = GMSMarker()
    
    var map : GMSMapView = GMSMapView()
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapView
        private var clusterManager: GMUClusterManager!
        
        init(_ parent: MapView) {
            self.parent = parent
            
           
        }
        private func generateClusterItems() {
            let extent = 0.2
            for _ in 1...kClusterItemCount {
                let lat = kCameraLatitude + extent * randomScale()
                let lng = kCameraLongitude + extent * randomScale()
                let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let marker = GMSMarker(position: position)
                clusterManager.add(marker)
            }
        }
        
        /// Returns a random value between -1.0 and 1.0.
        private func randomScale() -> Double {
            return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
        }
        // Implement GMSMapViewDelegate methods here
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            
            /*
            
            let positionLondon = CLLocationCoordinate2D(latitude: 37.3805, longitude: -122.050)
            let london = GMSMarker(position: positionLondon)
            
            let markerImage = UIImage(systemName: "gear.fill")!.withRenderingMode(.alwaysTemplate)
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = UIColor.yellow
            london.title = "caracas"
            london.iconView = markerView
            london.map = mapView
            */
            
            print(coordinate.latitude)
            print("my tag")
            print(mapView)
            print("------")
            
            // Set up the cluster manager with default icon generator and renderer.
            let iconGenerator = GMUDefaultClusterIconGenerator()
            let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
            let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
            clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
            
            // Register self to listen to GMSMapViewDelegate events.
            clusterManager.setMapDelegate(self)
            
            // Generate and add random items to the cluster manager.
            generateClusterItems()
            
            // Call cluster() after items have been added to perform the clustering and rendering on map.
            clusterManager.cluster()
            // Handle tap events
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            // Se llama cuando se toca la ventana de información de un marcador específico
            //print(marker.title)
            //mapView.settings.setAllGesturesEnabled(false)
        }
        
        func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
            //print(overlay.zIndex)
            
            // Se llama cuando se toca una superposición en el mapa
        }
        
        
        
        
        // Add more delegate methods as needed
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.camera = GMSCameraPosition(latitude: 37.36, longitude: -122.0
                                           , zoom: 20.0
        )
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        
        mapView.settings.myLocationButton = true
        
        mapView.delegate = context.coordinator
        mapView.tag = 12474737
        print(mapView.tag)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        
        print("---------Google Maps 30.0\n\n")
        //print(self.lead.loadAll())
        
        for leadModel in lead.leads {
            print( leadModel)
            if let latitude = Double(leadModel.latitude),
               let longitude = Double(leadModel.longitude) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                marker.title = leadModel.first_name ?? leadModel.business_name
                marker.map = mapView
            }
        }
        
        // Puedes realizar actualizaciones adicionales aquí
        marker.position = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        let rectanglePath = GMSMutablePath()
        rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
        rectanglePath.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.0))
        rectanglePath.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.2))
        rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.2))
        rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
        
        let rectangle = GMSPolyline(path: rectanglePath)
        rectangle.map = mapView
        
        
        // Create a rectangular path
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
        rect.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.0))
        rect.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.2))
        rect.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.2))
        
        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        let circleCenter = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0)
        let circle = GMSCircle(position: circleCenter, radius: 1000)
        circle.map = mapView
        
        let positionLondon = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0)
        let london = GMSMarker(position: positionLondon)
        
        let markerImage = UIImage(systemName: "house.fill")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.tintColor = UIColor.red
        london.title = "London"
        london.iconView = markerView
        london.map = mapView
        
        print("my tag 1.0")
        print(mapView)
        print("------")
        
    }
    
    
    
    
}

struct ContentView: View {
    var body: some View {
        MapView()
            .edgesIgnoringSafeArea(.all)
            .environmentObject(LeadViewModel(first_name: "Juan", last_name: ""))
    }
}

#Preview ("yanny") {
   Text("Hola")
}
