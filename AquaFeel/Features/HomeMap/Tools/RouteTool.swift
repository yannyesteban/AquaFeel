//
//  RouteTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/4/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class RouteTool: NSObject, MapTool, GMSMapViewDelegate {
    var onPath: ((GMSMutablePath) -> Void)?
    
    var onDraw: ((GMSMarker) -> Void)?
    
    var map: GMSMapView
    var onPlay = false
    
    var marker = GMSMarker()
    var position: CLLocationCoordinate2D?
    
    override init() {
        map = GMSMapView()
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
            onDraw?(self.marker)
        }
        
        
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        stop()
    }
}
