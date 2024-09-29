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

    func start() {
        setupLocationManager()
        requestLocation()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // location = locationManager.location?.coordinate

        // locationManager.startUpdatingLocation()
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

    private func checkLocationAuthorizationStatus() -> Bool {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // El usuario no ha decidido si permitir o no la ubicación
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // El acceso a la ubicación está restringido o denegado
            print("El acceso a la ubicación está restringido o denegado")
        // Aquí podrías mostrar una alerta o mensaje al usuario.
        case .authorizedWhenInUse, .authorizedAlways:
            // El usuario ha permitido el acceso a la ubicación
            // locationManager.startUpdatingLocation()
            return true
        @unknown default:
            // Manejar cualquier caso futuro que pueda surgir
            print("Estado de autorización desconocido")
        }

        return false
    }
}
