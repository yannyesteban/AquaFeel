//
//  MarkTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/4/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class MarkTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    @Published var ready = false
    @Published var position: CLLocationCoordinate2D?
    var onPath: ((GMSMutablePath) -> Void)?

    var onDraw: ((GMSMarker) -> Void)?

    var map: GMSMapView
    var onPlay = false

    var marker = GMSMarker()
    

    override init() {
        map = GMSMapView()
    }
    
    func setMap(map: MapsProvider) {
        
        
    }

    func setMap(map: GMSMapView) {
        self.map = map

        
    }

    func play() {
        marker.map = map
        self.map.delegate = self
        marker.snippet = "Generic"
    }

    func stop() {
        marker.map = nil
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker == self.marker {
            ready = true
            onDraw?(self.marker)
        }else{
            ready = false
        }
        
       

        return true
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        position = coordinate
        marker.position = coordinate
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        stop()
    }
}
