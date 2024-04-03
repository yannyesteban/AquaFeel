//
//  ToolManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/4/24.
//

import Foundation
import GoogleMaps

protocol MapTool {
    func setMap(map: GMSMapView)
    func play()
    func stop()
    
    var onPath : ((GMSMutablePath) -> Void)? { get set }
    var onDraw : ((GMSMarker) -> Void)? { get set }
}

enum ToolMode {
    case lasso
    case marker
    case route
    case cluster
    case none
}

class ToolManager: ObservableObject {
    @Published var mode = ToolMode.none
    @Published var mapTools: [ToolMode: MapTool] = [:]
    @Published var tool: MapTool?

    @Published var lasso = GMSMutablePath()
    @Published var marker = GMSMarker()
    @Published var lead: LeadModel?
    
    @Published var ready = false
    
    //@Published var lassoEnded = false
    //@Published var markEnded = false

    //var map: GMSMapView
    func initTool(mode: ToolMode, tool: MapTool){
        
        mapTools[mode] = tool
        
        
        
    }
    func setTool(_ newMode: ToolMode) {
        
        print("newMode: ", newMode)
        stop()
        if newMode == mode || newMode == .none{
            tool = nil
            mode = .none
            return
        }
        
        
        tool = mapTools[newMode]
        mode = newMode
        play()
    }

    func toggle(_ thisMode: ToolMode, _ orMode: ToolMode) {
        stop()
        if thisMode == mode {
            setTool(orMode)
        } else {
            setTool(thisMode)
        }
        
    }
    func play() {
        tool?.play()
    }

    func stop() {
        tool?.stop()
    }
}
