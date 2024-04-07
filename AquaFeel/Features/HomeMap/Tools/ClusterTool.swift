//
//  ClusterTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/4/24.
//

import Foundation

import Foundation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

class ClusterTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    var onPath: ((GMSMutablePath) -> Void)?

    var onDraw: ((GMSMarker) -> Void)?

    var map: GMSMapView
    var onPlay = false

    var position: CLLocationCoordinate2D?

    var clusterManager: GMUClusterManager?
    var groups: [String: MultiMark] = [:]
    
    var lastMarker: GMSMarker?

    override init() {
        map = GMSMapView()
    }

    func setMap(map: GMSMapView) {
        self.map = map

        self.map.delegate = self

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        renderer.maximumClusterZoom = 15

        clusterManager = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)

        clusterManager?.cluster()
    }

    func play() {
        map.delegate = self
    }

    func stop() {
    }

    func truncateCoordinates(_ coordinate: CLLocationCoordinate2D, toDecimals decimals: Int) -> CLLocationCoordinate2D {
        let lat = Double(String(format: "%.\(decimals)f", coordinate.latitude))!
        let lon = Double(String(format: "%.\(decimals)f", coordinate.longitude))!
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func truncateCoordinatesStr(_ coordinate: CLLocationCoordinate2D, toDecimals decimals: Int) -> String {
        let lat = String(format: "%.\(decimals)f", coordinate.latitude)
        let lon = String(format: "%.\(decimals)f", coordinate.longitude)
        return lat + lon
    }

    func add(marker: GMSMarker) {
        if let clusterManager = clusterManager {
            clusterManager.add(marker)

            let coordinate = truncateCoordinatesStr(marker.position, toDecimals: 6)

            if groups[coordinate] != nil {
                groups[coordinate]?.markers.append(marker)

            } else {
                groups[coordinate] = .init()
                groups[coordinate]?.markers = [marker]
            }

            if groups[coordinate]?.markers.count ?? 0 > 1 {
                let center = truncateCoordinates(marker.position, toDecimals: 6)

                groups[coordinate]?.draw(center: center, radio: 15, map: map, manager: clusterManager)
            }
        }
    }

    func loadMarkers(markers: [GMSMarker]) {
        resetCluster()

        for marker in markers {
            add(marker: marker)
        }
    }

    func resetCluster() {
        groups = [:]
        clusterManager?.clearItems()
    }
    
    func unSelect(){
        if let last = lastMarker {
            if let sublayers = last.iconView?.layer.sublayers {
                if let lastLayer = sublayers.last {
                    lastLayer.borderWidth = 0.0
                    // Modificar la capa recién agregada
                    // lastLayer.cornerRadius = (marker.iconView?.bounds.width ?? 0) / 2
                    
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        unSelect()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)

        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)

            return false
        }
        unSelect()
       
        if let sublayers = marker.iconView?.layer.sublayers {
            if let lastLayer = sublayers.last {
                lastLayer.borderWidth = 3.0
                // Modificar la capa recién agregada
                // lastLayer.cornerRadius = (marker.iconView?.bounds.width ?? 0) / 2
                
            }
        }
        lastMarker = marker
        onDraw?(marker)
        return true
    }
}
