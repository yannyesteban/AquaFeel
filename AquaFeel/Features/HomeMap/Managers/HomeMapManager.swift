//
//  HomeMapManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 31/3/24.
//

import Foundation
import GoogleMaps

class HomeMapManager: ObservableObject {
    @Published var lead: LeadModel?
    @Published var lastLead = 0
    @Published var lastMarker: GMSMarker?
    @Published var state: MapState = .none
    @Published var zoom: Int = 0
    @Published var bounds: GMSCoordinateBounds?
    @Published var route: RouteResponse?
    @Published var lastRoute = 0
    
    func setLassoTool(){
        state = .lasso
    }
    
}
