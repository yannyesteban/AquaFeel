//
//  LassoTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 31/3/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class LassoTool: NSObject,  GMSMapViewDelegate, ObservableObject {
    var map: GMSMapView
    var onPlay = false
    var draw: Draw

    var drawPlay = true
    var drawing = false
    var firstPoint: CLLocationCoordinate2D?

    var path = GMSMutablePath()
    @Published var newPath = GMSMutablePath()
    @ObservedObject var data = MapData()

    override init() {
        map = GMSMapView()
        draw = Draw(map: map)
    }

    func setData(data:MapData){
        self.data = data
        
    }
    func setMap(map: GMSMapView) {
        self.map = map
        draw = Draw(map: map)

        self.map.delegate = self
    }

    func play() {
        // view.map.delegate = self

        print("play()")
        map.settings.setAllGesturesEnabled(false)

        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(recognizer(_:)))
        map.addGestureRecognizer(resetGestureRecognizer)

        map.delegate = self
        // resetGestureRecognizer.delegate = self

        resetGestureRecognizer.cancelsTouchesInView = false
        onPlay = true
        drawPlay = true
    }

    func stop() {
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("didTapAt lasso")
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("willMove ... 123")
    }

    @objc
    func recognizer(_ gesture: DragDropGestureRecognizer) {
        print("resetPieces")
        let location = gesture.location(in: map)
        if let tappedView = map.hitTest(location, with: nil) {
            if tappedView.self is UIButton {
                return
            }

            if tappedView == map {
                print("tappedView == map")
                return
            }
        }

        switch gesture.state {
        case .began:

            print(".began")
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)

            firstPoint = coordinate

        case .changed:
            print(".changed")
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)

            if !drawing, let firstPoint = firstPoint {
                draw.add(coordinate: firstPoint)
            }
            drawing = true

            draw.add(coordinate: coordinate)

        case .ended:
            print(".ended")
            if drawing {
                draw.bye()
            } else {
                // showLeadsOptions()
            }
            drawing = false

            data.test = "yanny esteban"
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
