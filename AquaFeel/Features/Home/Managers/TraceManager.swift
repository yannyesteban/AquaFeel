//
//  TraceManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 15/4/24.
//

import CoreLocation
import Foundation
import SwiftUI

class TraceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var follow = true
    @Published var position: CLLocationCoordinate2D?

    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        play()
    }

    func play() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        locationManager.startUpdatingLocation()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
    }

    func goto() {
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let position = locations.first?.coordinate {
            if let last = self.position {
                if last.latitude == position.latitude && last.longitude == position.longitude {
                    return
                }
            }

            DispatchQueue.main.async {
                if self.follow {
                    self.position = position
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
