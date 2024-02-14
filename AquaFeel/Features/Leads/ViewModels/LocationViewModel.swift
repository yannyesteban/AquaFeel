//
//  LocationViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import Foundation
import GoogleMaps


class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        print("INIT")
        //setupLocationManager()
    }
    
    func start(){
        print("start")
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        print("setupLocationManager")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func requestLocation() {
        print("requestLocation")
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first?.coordinate {
            print("didUpdateLocations ", location.latitude, location.longitude)
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("didFailWithError")
        print("Error al obtener la ubicación: \(error.localizedDescription)")
    }
}
