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

@MainActor
class ClusterTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    var onPath: ((GMSMutablePath) -> Void)?

    var onDraw: ((GMSMarker) -> Void)?

    var map: GMSMapView
    // var mapProvider: MapsProvider
    var onPlay = false

    var position: CLLocationCoordinate2D?

    var clusterManager: GMUClusterManager?
    var groups: [String: MultiMark] = [:]

    var lastMarker: GMSMarker?

    @Published var markers: [GMSMarker] = []
    @Published var maximumClusterZoom:UInt = 13
    @Published var minimumClusterSize:UInt = 10
    override init() {
        map = GMSMapView()
    }

    func setMap(map: MapsProvider) {
    }

    func setMap(map: GMSMapView) {
        self.map = map

        self.map.delegate = self

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        renderer.maximumClusterZoom = maximumClusterZoom
        renderer.minimumClusterSize = minimumClusterSize
        
      
        // algorithm.clusters(atZoom: 12)

        clusterManager = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)

        clusterManager?.cluster()
    }

    func play() {
     
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        map.delegate = self
        // loadMarkers()
    }

    func stop() {
        // clusterManager?.clearItems()
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

    func goto(lead: LeadModel) {
        let latitude = Double(lead.latitude) ?? 0.0
        let longitude = Double(lead.longitude) ?? 0.0
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let cameraUpdate = GMSCameraUpdate.setTarget(position)

        map.animate(with: cameraUpdate)
    }

    func goto(position: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(position)

        map.animate(with: cameraUpdate)
    }
    
    func zoom(zoom: Float) {
        map.animate(toZoom: zoom)
    }

    func find(id leadId: String) -> GMSMarker? {
        for marker in markers {
            if let lead = marker.userData as? LeadModel {
                if lead.id == leadId {
                    return marker
                }
            }
        }

        return nil
    }

    func highlight(id: String) -> Bool {
        guard let marker = find(id: id) else {
            return false
        }

        map.animate(toLocation: marker.position)
        map.animate(toZoom: 15.0)

        if let _ = marker.userData as? GMUCluster {
            map.animate(toZoom: map.camera.zoom + 1)
            map.animate(toZoom: 15.0)
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
        // onDraw?(marker)
        return true
    }

    func addMarkers(markers: [GMSMarker]) {
        self.markers += markers

       
      
        // DispatchQueue.main.async {

        for marker in markers {
            add(marker: marker)
        }
        clusterManager?.cluster()
        // }

       
    }

    func loadMarkers() {
        resetCluster()

        for marker in markers {
            add(marker: marker)
        }

    
    }

    func loadMarkers(markers: [GMSMarker]) {
        resetCluster()

        self.markers = markers

        DispatchQueue.main.async {
          
            for marker in markers {
                self.add(marker: marker)
            }
        }
    }

    func resetCluster() {
    
        groups = [:]
        markers = []
        clusterManager?.clearItems()
        clusterManager?.cluster()
    }

    func unSelect() {
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

    func deleteMarker(leadId: String) {
        // Buscar el marker
        guard let index = markers.firstIndex(where: { ($0.userData as? LeadModel)?.id == leadId }),
              let lead = markers[index].userData as? LeadModel else { return }

   
        // Eliminar de todas las estructuras
        let marker = markers[index]
        clusterManager?.remove(marker)
        markers.remove(at: index)

        // Actualizar grupos
        let coordinateKey = truncateCoordinatesStr(lead.position, toDecimals: 6)
        // groups[coordinateKey]?.markers.removeAll(where: { $0 == marker })
      
        if let group = groups[coordinateKey] {
            // Filtrar markers manteniendo solo los que no coinciden

            group.markers.removeAll { existingMarker in
                if let existingLead = existingMarker.userData as? LeadModel {
                    return existingLead.id == leadId
                }
                return false
            }
           
            // Actualizar o eliminar el grupo
            if group.markers.isEmpty {
                groups.removeValue(forKey: coordinateKey)
                clusterManager?.remove(marker)
            } else {
                groups[coordinateKey] = group
                // Actualizar representación visual del grupo
                group.draw(map: map, manager: clusterManager!)
                
            }
            
        }
        clusterManager?.cluster()
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
