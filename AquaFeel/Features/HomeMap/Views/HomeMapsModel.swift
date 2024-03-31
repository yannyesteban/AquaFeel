//
//  HomeMapsModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils


protocol MapTool {
    init (map: GMSMapView)
    func play()
    func stop()
}

class MultiMark {
    
    var markers: [GMSMarker] = []
    var circle: GMSCircle?
    var paths: [GMSMutablePath] = []
    var polylines: [GMSPolyline] = []

    func draw(center: CLLocationCoordinate2D, radio: CLLocationDistance, map: GMSMapView, manager: GMUClusterManager) {
        circle = GMSCircle(position: center, radius: radio)
        circle?.strokeWidth = 1.0
        circle?.strokeColor = .orange

        circle?.map = map

        calculateMarkersAround(center: center, distance: radio, manager: manager)

        for i in polylines.indices {
            polylines[i].map = nil
        }

        for i in paths.indices {
            paths[i].removeAllCoordinates()
        }

        for marker in markers {
            let path = GMSMutablePath()
            path.add(center)
            path.add(marker.position)

            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .orange
            polyline.strokeWidth = 1.0

            polyline.map = map
            paths.append(path)
            polylines.append(polyline)
        }
    }

    func calculateMarkersAround(center: CLLocationCoordinate2D, distance: CLLocationDistance, manager: GMUClusterManager) {
        // Calcular el ángulo entre cada marcador
        let angleStep = 360.0 / Double(markers.count)

        // Calcular las posiciones de los marcadores adicionales
        for i in 0 ..< markers.count {
            let angle = angleStep * Double(i)
            let x = distance * cos(angle * .pi / 180.0)
            let y = distance * sin(angle * .pi / 180.0)

            let newLatitude = center.latitude + (y / 111111.0)
            let newLongitude = center.longitude + (x / (111111.0 * cos(center.latitude * .pi / 180.0)))

            let newPosition = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)

            manager.remove(markers[i])
            markers[i].position = newPosition
            markers[i].groundAnchor = CGPoint(x: 0.5, y: 0.5)
            manager.add(markers[i])
        }
    }
}
