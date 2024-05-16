//
//  LocationTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/4/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class LocationTool: NSObject, ObservableObject, MapTool, CLLocationManagerDelegate {
    var onPath: ((GMSMutablePath) -> Void)?

    var onDraw: ((GMSMarker) -> Void)?

    var map: GMSMapView
    var onPlay = false
    
    @Published var follow = false

    var marker = GMSMarker()
    var position: CLLocationCoordinate2D?

    private var locationManager = CLLocationManager()

    override init() {
        map = GMSMapView()
    }

    func setMap(map: MapsProvider) {
        
        
    }
    func setMap(map: GMSMapView) {
        self.map = map
        marker.map = map
    }

    func play() {
        marker.zIndex = -1
        /*marker.groundAnchor = CGPointMake(0.5, 0.5)
        marker.zIndex = -1
        let circleBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        circleBackgroundView.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        circleBackgroundView.layer.cornerRadius = 15 // Radio de la esquina para hacerla circular
        circleBackgroundView.clipsToBounds = true
        
        // Crear la vista del icono del marcador
        let circleIconView = UIImageView(image: UIImage(systemName: "car.fill"))
        circleIconView.contentMode = .scaleAspectFit
        circleIconView.tintColor = .yellow
        circleIconView.frame =  CGRect(x: 5, y: 5, width: 20, height: 20)
        
        // Agregar la vista circular de fondo como una subvista del icono del marcador
        //circleIconView.addSubview(circleBackgroundView)
        circleBackgroundView.addSubview(circleIconView)
        // Configurar el marcador con la vista del icono
        marker.iconView = circleBackgroundView
         */
        marker.icon?.withTintColor(.green)
        marker.map = map

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        locationManager.startUpdatingLocation()
    }

    func stop() {
        marker.map = nil
        locationManager.stopUpdatingLocation()
    }
    
    func goto(marker: GMSMarker) {
        let markerPosition = marker.position
        
        let cameraUpdate = GMSCameraUpdate.setTarget(markerPosition)
        
        map.animate(with: cameraUpdate)
    }
    
    func myLocation(){
        if let location = locationManager.location?.coordinate {
            
            let cameraUpdate = GMSCameraUpdate.setTarget(location)
            
            map.animate(with: cameraUpdate)
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let position = locations.first?.coordinate {
            self.position = position

            marker.position = position
            
            if follow {
                goto(marker: marker)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
