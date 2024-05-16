//
//  LassoTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 31/3/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class LassoTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    var onDraw: ((GMSMarker) -> Void)?
    var onPath: ((GMSMutablePath) -> Void)?

    var map: GMSMapView
    var onPlay = false
    var draw: Draw

    var drawPlay = true
    var drawing = false
    var firstPoint: CLLocationCoordinate2D?

    @Published var path = GMSMutablePath()
    @Published var ready = false
    var newPath = GMSMutablePath()

    override init() {
        map = GMSMapView()
        draw = Draw(map: map)
    }
    
    func setMap(map: MapsProvider) {
        
        
    }

    func setMap(map: GMSMapView) {
        self.map = map
        draw = Draw(map: map)

        self.map.delegate = self
    }

    func play() {
        map.settings.setAllGesturesEnabled(false)

        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(recognizer(_:)))
        map.addGestureRecognizer(resetGestureRecognizer)

        map.delegate = self

        onPlay = true
        drawPlay = true
    }

    func stop() {
        map.settings.setAllGesturesEnabled(true)
        draw.stop()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }

    @objc
    func recognizer(_ gesture: DragDropGestureRecognizer) {
        let location = gesture.location(in: map)
        if let tappedView = map.hitTest(location, with: nil) {
            if tappedView.self is UIButton {
                return
            }

            if tappedView == map {
                return
            }
        }

        switch gesture.state {
        case .began:
            ready = false

            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)

            firstPoint = coordinate

        case .changed:

            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)

            if !drawing, let firstPoint = firstPoint {
                draw.add(coordinate: firstPoint)
            }
            drawing = true

            draw.add(coordinate: coordinate)

        case .ended:

            if drawing {
                draw.bye()
            } else {
                ready = true
                onPath?(path)
            }
            drawing = false

            path = GMSMutablePath(path: draw.path2)
            newPath = GMSMutablePath(path: draw.path2)

        default:
            break
        }
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}
