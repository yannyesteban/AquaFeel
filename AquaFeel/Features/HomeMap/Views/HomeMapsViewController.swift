//
//  HomeMapsViewController.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

class MapsCluster: NSObject {
    var clusterManager: GMUClusterManager?
    var map: GMSMapView!
    var groups: [String: MultiMark] = [:]
    init(map: GMSMapView) {
        self.map = map
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        renderer.maximumClusterZoom = 15
        super.init()
        clusterManager = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)

        // clusterManager?.setDelegate(self, mapDelegate: self)

        clusterManager?.cluster()
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

    func add(marker: GMSMarker) {
        if let clusterManager = clusterManager {
            clusterManager.add(marker)

            let coordinate = truncateCoordinatesStr(marker.position, toDecimals: 6)

            if groups[coordinate] != nil {
                groups[coordinate]?.markers.append(marker)

            } else {
                groups[coordinate] = .init()
                groups[coordinate]?.markers = [marker]
            }

            if groups[coordinate]?.markers.count ?? 0 > 1 {
                let center = truncateCoordinates(marker.position, toDecimals: 6)

                groups[coordinate]?.draw(center: center, radio: 15, map: map, manager: clusterManager)
            }
        }
    }

    func resetCluster() {
        // let manager = initCluster()
        clusterManager?.clearItems()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)

        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)

            print("......Did tap cluster")
            return false
        }

        print(".....Did tap marker")

        return false
    }
}

class HomeMapsViewController: UIViewController {
    let map = GMSMapView()

    var location: CLLocationCoordinate2D?
    
    var markerDictionary: [Int: GMSMarker] = [:]
    var lastMarker: Int?

    var lastCluster = "default"
    var clusters: [String: MapsCluster] = [:]
    var clusterManager: GMUClusterManager!

    var markers: [GMSMarker] = []
    
    init(location: CLLocationCoordinate2D){
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        
        var longitude = -74.0060 // -74.0060 // -122.008972 //-122.008972
        var latitude = 40.7128 // 40.7128 // 39.2750209// 37.33464379999999
        
        if let location = location {
            longitude = location.longitude
            latitude = location.latitude
        }
        // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
        map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        
        
        view = map

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // _ = initCluster()
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        
        clusterManager = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)
        
        // clusterManager.setDelegate(self, mapDelegate: self)
        
        clusterManager.cluster()
    }
    
    func setCluster(name: String, cluster: MapsCluster) {
        clusters[name] = cluster
    }

    func getCluster(name: String) -> MapsCluster? {
        return clusters[name]
    }

    func initCluster() -> GMUClusterManager {
        /* let clusterManager: GMUClusterManager!
         if clusters[lastCluster] != nil {
             clusterManager = clusters[lastCluster]
         } else {
             let iconGenerator = GMUDefaultClusterIconGenerator()
             let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
             let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)

             clusterManager = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)

              clusterManager.setDelegate(self, mapDelegate: self)

             clusterManager.cluster()

             clusters[lastCluster] = clusterManager
         } */

        return clusterManager
    }

    func resetCluster() {
        // let manager = initCluster()
        clusterManager.clearItems()
    }

    func fitBounds(bounds: GMSCoordinateBounds) {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        map.animate(with: update)
        // map.moveCamera(update)
    }

    func addMarker(marker: GMSMarker) {
        marker.map = map
    }

    func addItem(_ marker: GMSMarker) {
        let manager = initCluster()
        /*
         let marker = GMSMarker()
         marker.position = marker1.position

         marker.isTappable = true

         //marker.userData = lead

         //print(lead.status_id.name)
         let circleIconView = getUIImage(name: "WIN")
         circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)

         let circleLayer = CALayer()
         circleLayer.bounds = circleIconView.bounds
         circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
         circleLayer.cornerRadius = circleIconView.bounds.width / 2
         circleLayer.borderWidth = 0.0
         circleLayer.borderColor = UIColor.black.cgColor

         circleIconView.layer.addSublayer(circleLayer)

         marker.iconView = circleIconView

         markers.append(marker)
          */
        clusterManager.add(marker)

        clusterManager.cluster()
    }

    func drawMarker(leads: [LeadModel]) {
        print("drawMarker")

        for lead in leads {
            let latitude = Double(lead.latitude) ?? 0.0
            let longitude = Double(lead.longitude) ?? 0.0
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            let marker = GMSMarker(position: position)
            markerDictionary[lead.routeOrder] = marker

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
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .systemTeal
            label.layer.cornerRadius = 15
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = lead.routeOrder.formatted() // Coloca el número deseado aquí
            marker.iconView = label
            // marker.iconView = markerImageView
            // Ajustar el tamaño del icono del marcador

            /*
             markerImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
             */

            /*
             let customView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

             // Agregar el icono al customView
             let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
             iconImageView.image = UIImage(systemName: "trash.circle.fill") // Icono de bote de basura
             iconImageView.tintColor = .red // Color del icono
             customView.addSubview(iconImageView)

             // Agregar el número al customView
             let label = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
             label.textAlignment = .center
             label.textColor = .white
             label.backgroundColor = .blue
             label.layer.cornerRadius = 5
             label.clipsToBounds = true
             label.font = UIFont.boldSystemFont(ofSize: 20)
             label.text = lead.routeOrder.formatted() // Número del marcador
             customView.addSubview(label)
             marker.iconView = customView
             */

            // Establecer el customView como el iconView del marcador

            marker.map = map
        }
    }

    func drawRoute(routes: [Route]) {
        map.clear()
        markerDictionary = [:]
        for route in routes {
            let bounds = route.bounds
            let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
            let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
            fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let path = GMSPath(fromEncodedPath: route.overviewPolyline.points)
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = UIColor.orange
                polyline.strokeWidth = 4.0
                polyline.map = self.map
            }

            UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
                self.drawMarker(leads: route.leads)
            }, completion: nil)

            /*

             let path = GMSPath(fromEncodedPath: route.overviewPolyline.points)
             let polyline = GMSPolyline(path: path)
             polyline.strokeColor = UIColor.orange
             polyline.strokeWidth = 4.0
             polyline.map = map

             markerDictionary = [:]
             drawMarker(leads: route.leads)
             */
        }
    }

    func goto(lead: LeadModel) {
        let latitude = Double(lead.latitude) ?? 0.0
        let longitude = Double(lead.longitude) ?? 0.0
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let cameraUpdate = GMSCameraUpdate.setTarget(position)

        if let last = lastMarker {
            markerDictionary[last]?.iconView?.backgroundColor = .systemTeal
        }
        markerDictionary[lead.routeOrder]?.iconView?.backgroundColor = .red
        lastMarker = lead.routeOrder
        map.animate(with: cameraUpdate)
    }

    func goto(marker: GMSMarker) {
        let markerPosition = marker.position

        let cameraUpdate = GMSCameraUpdate.setTarget(markerPosition)

        map.animate(with: cameraUpdate)
    }

    func setLeads(leads: [LeadModel]) {
        resetCluster()

        for lead in leads {
            let marker = GMSMarker()
            marker.position = lead.position

            marker.isTappable = true

            marker.userData = lead

            print(lead.status_id.name)
            let circleIconView = getUIImage(name: lead.status_id.name)
            circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)

            let circleLayer = CALayer()
            circleLayer.bounds = circleIconView.bounds
            circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
            circleLayer.cornerRadius = circleIconView.bounds.width / 2
            circleLayer.borderWidth = 0.0
            circleLayer.borderColor = UIColor.black.cgColor

            circleIconView.layer.addSublayer(circleLayer)

            marker.iconView = circleIconView

            addItem(marker)
        }
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}
