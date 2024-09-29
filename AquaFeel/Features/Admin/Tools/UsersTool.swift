//
//  UsersTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/4/24.
//

import Foundation

import GoogleMaps
import SwiftUI

class UsersTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    
    var onPath: ((GMSMutablePath) -> Void)?
    
    var onDraw: ((GMSMarker) -> Void)?
    
    var map: GMSMapView
    var onPlay = false
    
    var marker = GMSMarker()
    
    
    override init() {
        map = GMSMapView()
    }
    
    func setMap(map: MapsProvider) {
        
        
    }
    
    func setMap(map: GMSMapView) {
        self.map = map
        
        
    }
    
    func draw(users: [User]){
        for user in users {
            let marker = createMarkerWithInitials(user: user)
            marker.position = user.position
            marker.userData = user
            marker.map = map
        }
    }
    
    func createMarkerWithInitials(user: User) -> GMSMarker {
        // Obtener las iniciales del nombre y apellido del usuario
        let initials = "\(user.firstName.first ?? " ")\(user.lastName.first ?? " ")"
        
        // Crear una vista para el círculo con las iniciales
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
       
        
        
        circleView.layer.cornerRadius = 15 // Hacer que la vista sea un círculo
        circleView.clipsToBounds = true
        
        // Crear una etiqueta para mostrar las iniciales
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.textColor = .white // Puedes personalizar el color del texto
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.text = initials
        let limit = 5
        if let lastPosition = user.mLastConnected {
            if lastPosition >= 0 && lastPosition <= limit {
                circleView.backgroundColor = .green // Puedes personalizar el color del círculo
                label.textColor = .blue
            } else if lastPosition >= limit && lastPosition <= 100 {
                circleView.backgroundColor = .blue // Puedes personalizar el color del círculo
            } else {
                circleView.backgroundColor = .red
            }
            
        } else {
            circleView.backgroundColor = .red
        }
        
        // Agregar la etiqueta a la vista del círculo
        circleView.addSubview(label)
        /*
        // Convertir la vista del círculo en una imagen
        UIGraphicsBeginImageContextWithOptions(circleView.bounds.size, false, 0.0)
        circleView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        */
        // Crear el marcador con la imagen que acabamos de generar
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0))
        marker.iconView = circleView
        marker.title = "\(user.firstName) \(user.lastName)"
        
        return marker
    }
    
    func play() {
        
        self.map.delegate = self
        
    }
    
    
    func goto(position: CLLocationCoordinate2D) {
       
        let cameraUpdate = GMSCameraUpdate.setTarget(position, zoom: 18)
        
        map.animate(with: cameraUpdate)
    }

    
    
    func stop() {
        marker.map = nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
      
        DispatchQueue.main.async {
            self.onDraw?(marker)
        }
        
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
       
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        stop()
    }
}
