//
//  RouteTool.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/4/24.
//

import Foundation
import GoogleMaps
import SwiftUI

class RouteTool: NSObject, ObservableObject, MapTool, GMSMapViewDelegate {
    var onPath: ((GMSMutablePath) -> Void)?

    var onDraw: ((GMSMarker) -> Void)?

    var map: GMSMapView
    var onPlay = false

    var marker = GMSMarker()
    var position: CLLocationCoordinate2D?

    var markerDictionary: [Int: GMSMarker] = [:]
    // var lastMarker: Int?

    @Published var lead: LeadModel?
    @Published var revealStatus = false
    var lastLead = 0
    var lastMarker: GMSMarker?
    var state: MapState = .none
    var zoom: Int = 0
    var bounds: GMSCoordinateBounds?
    var route: RouteResponse?
    var lastRoute = 0
    var last: Int?
    var groups: [String: MultiMark] = [:]
    var polyline = GMSPolyline()
    var markers: [GMSMarker] = []

    var leadMarkers: [Int: GMSMarker] = [:]
    override init() {
        map = GMSMapView()
    }

    func setMap(map: MapsProvider) {
        
        
    }
    
    func setMap(map: GMSMapView) {
        self.map = map
    }

    func play() {
        map.settings.compassButton = false
        map.settings.zoomGestures = true
        map.settings.myLocationButton = false
        map.isMyLocationEnabled = false
        map.delegate = self
    }

    func stop() {
        reset()
    }

    func nextMark() {
        var index = lastLead
        if let myRoute = route?.routes[lastRoute] {
            index = (index % myRoute.leads.count) + 1

            find(index)
        }
        state = .next
    }

    func prevMark() {
        var index = lastLead
        if let myRoute = route?.routes[lastRoute] {
            if index == 1 {
                index = myRoute.leads.count
            } else {
                index -= 1
            }

            find(index)
        }

        state = .prev
    }

    func goto(lead: LeadModel) {
        let latitude = Double(lead.latitude) ?? 0.0
        let longitude = Double(lead.longitude) ?? 0.0
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let cameraUpdate = GMSCameraUpdate.setTarget(position)

        if let last = last {
            // markerDictionary[last]?.iconView = labelIcon(text: lead.routeOrder, color: .systemTeal)

            // markerDictionary[last]?.iconView?.backgroundColor = .systemTeal

            // marker.iconView = labelIcon(text: lead.routeOrder)
        }

        /*
         if revealStatus, let selected = markerDictionary[lead.routeOrder] {
             let circleIconView = getUIImage(name: lead.status_id.name)
             circleIconView.frame = CGRect(x: 120, y: 120, width: 25, height: 25)

             selected.iconView = circleIconView
         } else {
             markerDictionary[lead.routeOrder]?.iconView = labelIcon(text: lead.routeOrder, color: .red)
         }

          */
        last = lead.routeOrder
        map.animate(with: cameraUpdate)
    }

    func find(_ index: Int) {
        if let myRoute = route?.routes[lastRoute] {
            if let leadFound = myRoute.leads.first(where: { $0.routeOrder == index }) {
                lastLead = index
                lead = leadFound
                state = .tap
                goto(lead: leadFound)
            }
        }
    }

    func setBounds() {
        if let routes = route?.routes {
            for route in routes {
                let bounds = route.bounds
                let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
                let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
                fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))
            }
        }
    }

    func fitBounds(bounds: GMSCoordinateBounds) {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        map.animate(with: update)
    }

    func reset() {
        groups = [:]
        polyline.map = nil
        markerDictionary = [:]
        for market in markers {
            market.map = nil
        }
        markers = []
    }

    func labelIcon(text: Int, color: UIColor) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = color
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = text.formatted() // Coloca el número deseado aquí
        // marker.iconView = label

        return label
    }

    func drawMarker(leads: [LeadModel]) {
        // groups = [:]
        for lead in leads {
            /* let latitude = Double(lead.latitude) ?? 0.0
             let longitude = Double(lead.longitude) ?? 0.0
             let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

              */

            print("lead.position", lead.position.latitude)
            let marker = GMSMarker(position: lead.position)

            markerDictionary[lead.routeOrder] = marker

            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)

            marker.userData = lead.routeOrder
            // marker.icon = UIImage(systemName: "trash.circle.fill")
            /*
             let markerImageView = UIImageView(image: UIImage(systemName: "trash.circle.fill"))
             markerImageView.tintColor = .red

             markerImageView.layer.shadowColor = UIColor.black.cgColor
             markerImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
             markerImageView.layer.shadowOpacity = 0.7
             markerImageView.layer.shadowRadius = 3
             */
            /* let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
             label.textAlignment = .center
             label.textColor = .white
             label.backgroundColor = .systemTeal
             label.layer.cornerRadius = 15
             label.clipsToBounds = true
             label.font = UIFont.boldSystemFont(ofSize: 14)
             label.text = lead.routeOrder.formatted() // Coloca el número deseado aquí
             */
            // marker.iconView = labelIcon(text: lead.routeOrder, color: .systemTeal)

            // marker.iconView = markerImageView
            // Ajustar el tamaño del icono del marcador

            /*
             markerImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
             */

            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))

            let circleIconView = getUIImage(name: lead.status_id.name)
            circleIconView.frame = CGRect(x: 6, y: 6, width: 30, height: 30)

            // Agregar el icono al customView
            // let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            // iconImageView.image = UIImage(systemName: "trash.circle.fill") // Icono de bote de basura
            // iconImageView.tintColor = .red // Color del icono
            customView.addSubview(circleIconView)

            // Agregar el número al customView
            let label = UILabel(frame: CGRect(x: 2, y: 2, width: 20, height: 20))
            label.textAlignment = .center
            label.textColor = .black
            label.backgroundColor = .white
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 11)
            label.text = lead.routeOrder.formatted() // Número del marcador
            label.layer.borderWidth = 2.0
            label.layer.borderColor = UIColor.red.cgColor
            customView.addSubview(label)
            // customView.layer.borderColor = UIColor.blue.cgColor
            // customView.layer.borderWidth = 2.0
            marker.iconView = customView

            // Establecer el customView como el iconView del marcador
            leadMarkers[lead.routeOrder] = marker
            add(marker: marker)
            markers.append(marker)
        }
    }

    func add(marker: GMSMarker) {
        marker.map = map
        let coordinate = truncateCoordinatesStr(marker.position, toDecimals: 6)

        if groups[coordinate] != nil {
            groups[coordinate]?.markers.append(marker)

        } else {
            groups[coordinate] = .init()
            groups[coordinate]?.markers = [marker]
        }

        if groups[coordinate]?.markers.count ?? 0 > 1 {
            let center = truncateCoordinates(marker.position, toDecimals: 6)

            groups[coordinate]?.draw(center: center, radio: 15, map: map)
        }
    }

    func updateMarker() {
        if let myRoute = route?.routes[lastRoute], let lead = lead {
            if let index = myRoute.leads.firstIndex(where: { $0.routeOrder == lastLead }) {
                route?.routes[lastRoute].leads[index] = lead
            }
        }

        if let marker = leadMarkers[lastLead], let lead = lead {
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))

            let circleIconView = getUIImage(name: lead.status_id.name)
            circleIconView.frame = CGRect(x: 6, y: 6, width: 30, height: 30)

            // Agregar el icono al customView
            // let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            // iconImageView.image = UIImage(systemName: "trash.circle.fill") // Icono de bote de basura
            // iconImageView.tintColor = .red // Color del icono
            customView.addSubview(circleIconView)

            // Agregar el número al customView
            let label = UILabel(frame: CGRect(x: 2, y: 2, width: 20, height: 20))
            label.textAlignment = .center
            label.textColor = .black
            label.backgroundColor = .white
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 11)
            label.text = lead.routeOrder.formatted() // Número del marcador
            label.layer.borderWidth = 2.0
            label.layer.borderColor = UIColor.red.cgColor
            customView.addSubview(label)
            // customView.layer.borderColor = UIColor.blue.cgColor
            // customView.layer.borderWidth = 2.0
            marker.iconView = customView
        }
    }

    func drawRoute(routes: [Route]) {
        // polyline.map = nil
        // markerDictionary = [:]
        reset()
        for route in routes {
            let bounds = route.bounds
            let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
            let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
            fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let path = GMSPath(fromEncodedPath: route.overviewPolyline.points)
                self.polyline = GMSPolyline(path: path)
                self.polyline.strokeColor = UIColor.orange
                self.polyline.strokeWidth = 4.0
                self.polyline.map = self.map
            }

            UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
                self.drawMarker(leads: route.leads)
            }, completion: nil)
        }
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

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let index = marker.userData as? Int {
            find(index)
        }

        if marker == self.marker {
            onDraw?(marker)
        }
        mapView.animate(toLocation: marker.position)
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        stop()
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}
