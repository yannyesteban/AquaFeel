//
//  LocationViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import Foundation
import GoogleMaps


class PlaceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        setupLocationManager()
    }
    
    func start(){
       
        setupLocationManager()
        requestLocation()
    }
    
    private func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //location = locationManager.location?.coordinate
        
        //locationManager.startUpdatingLocation()
    }
    
    func requestLocation() {
       
        
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first?.coordinate {
            
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            
        print("error: \(error.localizedDescription)")
    }
    
    func setLocation() {
        location = locationManager.location?.coordinate
    }
}
