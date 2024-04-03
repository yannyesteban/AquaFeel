//
//  LocationTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/4/24.
//


import Foundation
import GoogleMaps
import SwiftUI

class LocationTool: NSObject, MapTool {
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
       
    }
    
    func stop() {
        marker.map = nil
    }
    
   
}
