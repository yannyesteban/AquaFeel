//
//  AppleMapsViewController.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 7/5/24.
//

import CoreLocation
import Foundation
import GoogleMaps
import MapKit
import SwiftUI

class AppleMapsDraw: NSObject, MapDraw, MKMapViewDelegate {
    var ready = false
    var drawing = false
    var firstPoint: CLLocationCoordinate2D?

    let mapView: MKMapView

    var polyline = MKPolyline()
    var polygon = MKPolygon()

    var path: [CLLocationCoordinate2D] = []

    //var start = false

    let strokeWidth = 1.0
    var color: UIColor = UIColor.purple

    init(map: MKMapView) {
        print("INIT MapDraw")
        mapView = map

        super.init()

        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(drawGesture(_:)))
        mapView.addGestureRecognizer(resetGestureRecognizer)

        mapView.delegate = self
    }
    
    func start(){
        
    }
    
    func stop() {
        mapView.removeOverlay(polyline)
        
        mapView.removeOverlay(polygon)
    }

    func doLine(_ path: [CLLocationCoordinate2D]) {
        let newPolyline = MKPolyline(coordinates: path, count: path.count)

        mapView.addOverlay(newPolyline)
        mapView.removeOverlay(polyline)
        polyline = newPolyline
    }

    func bye() {
        mapView.removeOverlay(polyline)

        mapView.removeOverlay(polygon)

        polygon = MKPolygon(coordinates: path, count: path.count)

        mapView.addOverlay(polygon)

        path.removeAll()
    }

    func doGeofence() {
    }

    func doPoly(_ path: [CLLocationCoordinate2D]) {
    }

    func add(coordinate: CLLocationCoordinate2D) {
        path.append(coordinate)
        

        doLine(path)
    }

    func play() {
    }

    

    func pause() {
    }

    func get() {
    }

    func reset() {
    }

    @objc
    func drawGesture(_ gesture: DragDropGestureRecognizer) {
        let location = gesture.location(in: mapView)
        if let tappedView = mapView.hitTest(location, with: nil) {
            if tappedView.self is UIButton {
                return
            }

            if tappedView == mapView {
                return
            }
        }

        switch gesture.state {
        case .began:
            ready = false

            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

            firstPoint = coordinate
            mapView.removeOverlay(polyline)
        case .changed:

            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

            if !drawing, let firstPoint = firstPoint {
                add(coordinate: firstPoint)
            }
            drawing = true

            add(coordinate: coordinate)

        case .ended:

            print("......ended")
            if drawing {
                bye()

            } else {
                ready = true
                // onPath?(path)
            }
            drawing = false
            print("......ended 2")
            mapView.removeOverlay(polyline)
            // path = GMSMutablePath(path: draw.path2)
            // newPath = GMSMutablePath(path: draw.path2)

        default:
            break
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            // Configurar el renderer para la línea
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = color
            polylineRenderer.lineWidth = strokeWidth
            polylineRenderer.lineDashPattern = [3, 3]
            return polylineRenderer
        } else if let polygon = overlay as? MKPolygon {
            // Configurar el renderer para el polígono
            let polygonRenderer = MKPolygonRenderer(polygon: polygon)
            polygonRenderer.strokeColor = color
            polygonRenderer.lineDashPattern = [3, 3]
            polygonRenderer.fillColor = color.withAlphaComponent(0.2)
            polygonRenderer.lineWidth = strokeWidth
            return polygonRenderer
        } else {
            // Devolver un renderer por defecto para otros tipos de overlay
            return MKOverlayRenderer()
        }
    }
}

enum PolyType {
    case polyline
    case polygone
}

class MapGeofence: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D = .init()

    var boundingMapRect: MKMapRect = .init()

    let type: PolyType
    let color: UIColor
    let borderWidth: CGFloat
    let alphaColor: CGFloat

    init(type: PolyType, color: UIColor, borderWidth: CGFloat, alphaColor: CGFloat) {
        self.type = type
        self.color = color
        self.borderWidth = borderWidth
        self.alphaColor = alphaColor
    }
}

final class MapItem: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let info: MarkerInfo?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        info = nil
    }

    init(info: MarkerInfo) {
        coordinate = info.position
        self.info = info
    }
}

struct MarkerInfo {
    let userData: LeadModel
    let position: CLLocationCoordinate2D
    let image: UIView
    let borderColor: UIColor
    let borderWidth: Float
}

protocol MapsProvider {
    func addMarker(info: MarkerInfo)
    func center(position: CLLocationCoordinate2D)
    func myTest()

    func setCluster()
}

class AppleMapsViewController: UIViewController, MKMapViewDelegate, MapsProvider {
    func myTest() {
        print("my Test Apple Maps")
    }

    let map = GMSMapView()
    var mapView = MKMapView()
    var location: CLLocationCoordinate2D?

    var markerDictionary: [Int: GMSMarker] = [:]
    var lastMarker: Int?

    var lastCluster = "default"
    var clusters: [String: MapsCluster] = [:]
    var lasso: AppleMapsDraw!

    var markers: [GMSMarker] = []

    init(location: CLLocationCoordinate2D) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }

    func getProvider() -> MapsProvider {
        return self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        mapView.delegate = self

        view = mapView
    }

    func addMarker(info: MarkerInfo) {
        print("xxxx1", info.userData.first_name)
        let annotation = MapItem(info: info)
        // annotation.coordinate = info.position
        // annotations.append(annotation)
        mapView.addAnnotation(annotation)
    }

    func center(position: CLLocationCoordinate2D) {
        let initialLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        /*
         let annotation = MKPointAnnotation()
         annotation.title = "Anotación 1"
         annotation.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
         mapView.addAnnotation(annotation)
          */
    }

    func setCluster() {
        print("return")
        return

        var annotations: [MKPointAnnotation] = [
        ]

        let annotation = MKPointAnnotation()
        annotation.title = "Anotación 1"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        annotations.append(annotation)

        let annotation2 = MKPointAnnotation()
        annotation2.title = "Anotación 2"
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0260)
        annotations.append(annotation2)
        let cluster = MKClusterAnnotation(memberAnnotations: annotations)
        // 2. Agrupa las anotaciones en un MKClusterAnnotation
        // let cluster = MKClusterAnnotation(memberAnnotations: annotations)

        print("xxxx2")

        // 3. Agrega el cluster al mapa
        mapView.addAnnotation(cluster)
        print("xxxx3")
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: mapView)
        let coordinates = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        print("aaaaaa", coordinates)
        // let annotation = MyCustomAnnotation(coordinate: coordinates)
        // mapView.addAnnotation(annotation)
    }

    @objc
    func recognizer(_ gesture: DragDropGestureRecognizer) {
        let location = gesture.location(in: mapView)
        if let tappedView = mapView.hitTest(location, with: nil) {
            if tappedView.self is UIButton {
                return
            }

            if tappedView == mapView {
                return
            }
        }

        switch gesture.state {
        case .began:
            print(".began1")

            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

            print(coordinate)

        case .changed:
            print(".changed1")

        case .ended:
            print(".ended1")

        default:
            print(".nothing1")
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("xxxx1")
        // mapView.delegate = self
        // setCluster()

        if 1 == 2 {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            mapView.addGestureRecognizer(tapGestureRecognizer)
        }

        // let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(recognizer(_:)))
        // mapView.addGestureRecognizer(resetGestureRecognizer)

        lasso = AppleMapsDraw(map: mapView)
        let resetGestureRecognizer = DragDropGestureRecognizer(target: lasso, action: #selector(lasso.drawGesture(_:)))
        mapView.addGestureRecognizer(resetGestureRecognizer)

        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        // Agregar anotaciones al mapa
        let locations = [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            CLLocationCoordinate2D(latitude: 37.7836, longitude: -122.4321),
            CLLocationCoordinate2D(latitude: 37.7933, longitude: -122.4227),
            CLLocationCoordinate2D(latitude: 37.7814, longitude: -122.4181),
            CLLocationCoordinate2D(latitude: 37.7887, longitude: -122.4025),
        ]
        /*
         for location in locations {
             let annotation = MapItem(coordinate: <#T##CLLocationCoordinate2D#>)
             annotation.coordinate = location
             //annotations.append(annotation)
             mapView.addAnnotation(annotation)
         }
         */
        // mapView.addAnnotations(annotations)

        // Configurar clusteres
        // let clusteringManager = MKClusterManager()
        // clusteringManager.delegate = self
        // mapView.clusterManager = clusteringManager

        /*
         // Configura la región inicial del mapa
         let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
         let regionRadius: CLLocationDistance = 1000
         let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

         // Agrega un marcador en la ubicación inicial
         let annotation = MKPointAnnotation()
         annotation.coordinate = initialLocation.coordinate
         annotation.title = "Ubicación inicial"
         mapView.addAnnotation(annotation)

         let coordinates =  [CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), .init(latitude: 37.7949, longitude: -122.4994)]
         let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

         // Agregar la polilínea al mapa
         mapView.addOverlay(polyline)

         mapView.setRegion(coordinateRegion, animated: true)

         //create two dummy locations
         let loc1 = CLLocationCoordinate2D.init(latitude: 40.741895, longitude: -73.989308)
         let loc2 = CLLocationCoordinate2D.init(latitude: 40.728448, longitude: -73.717996)

         //find route
         showRouteOnMap(pickupCoordinate: loc1, destinationCoordinate: loc2)
         */
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

    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, _ in
            guard let unwrappedResponse = response else { return }

            // for getting just one route
            if let route = unwrappedResponse.routes.first {
                // show on map
                self.mapView.addOverlay(route.polyline)
                // set the map area to show the route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }

            // if you want to show multiple routes then you can get all routes in a loop in the following statement
            // for route in unwrappedResponse.routes {}
        }
    }

    /*
     func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        // mapView.clusterManager.updateClustersIfNeeded()
     }
     */

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let item = annotation as? MapItem {
            // 2
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "mapItem")
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "mapItem")

            annotationView.annotation = item
            // annotationView.addSubview(getUIImage(name: item.info?.userData.status_id.name ?? "uc"))

            // annotationView.image =  UIImage(systemName: "car")
            // 3
            annotationView.clusteringIdentifier = "mapItemClustered"

            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
            let circleIconView = getUIImage(name: item.info?.userData.status_id.name ?? "uc")
            circleIconView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)

            customView.layer.borderColor = UIColor.blue.cgColor
            customView.layer.borderWidth = 0.0

            customView.addSubview(circleIconView)

            // Configurar el círculo alrededor del icono
            let circleLayer = CALayer()
            circleLayer.bounds = circleIconView.bounds
            circleLayer.position = CGPoint(x: circleIconView.bounds.midX + 5, y: circleIconView.bounds.midY + 5)
            circleLayer.cornerRadius = circleIconView.bounds.width / 2
            circleLayer.borderWidth = 0.0
            circleLayer.borderColor = UIColor.orange.cgColor

            customView.layer.addSublayer(circleLayer)

            // Asignar la vista personalizada al marcador
            annotationView.addSubview(customView)

           
            return annotationView
        } else if let cluster = annotation as? MKClusterAnnotation {
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterView")
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "clusterView")
            clusterView.annotation = cluster
            clusterView.image = UIImage(named: "cluster") // Asignar una imagen a la vista del cluster

            // Obtener el número de anotaciones en el cluster
            let annotationsCount = cluster.memberAnnotations.count
            // Crear una etiqueta para mostrar el número de anotaciones en el cluster
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            label.text = "\(annotationsCount)"
            label.textColor = .white
            label.textAlignment = .center
            label.backgroundColor = .blue
            label.layer.cornerRadius = 20
            label.layer.borderWidth = 2.0
            label.layer.borderColor = UIColor.yellow.cgColor
            label.clipsToBounds = true

            // Agregar la etiqueta como subvista de la vista de anotación del cluster
            clusterView.addSubview(label)
           
            return clusterView
        } else {
            
            return nil
        }
    }

    /*
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         guard !(annotation is MKClusterAnnotation) else {
             return nil
         }

         let identifier = "pin"
         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

         if annotationView == nil {
             annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
             annotationView?.canShowCallout = true
         } else {
             annotationView?.annotation = annotation
         }

         return annotationView
     }
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        return renderer
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Seleccionado una anotación
        print(4444444)
        if let annotation = view.annotation {
            print("Se seleccionó la anotación: \(annotation.title ?? "")")
            // Aquí puedes realizar cualquier acción que desees cuando se seleccione una anotación
        }
    }

    func mapView(_ mapView: MKMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(4444444)
        // Realizado un toque en el mapa (fuera de cualquier anotación)
        print("Se realizó un toque en el mapa en la ubicación: \(coordinate)")
        // Aquí puedes realizar cualquier acción que desees cuando se toque el mapa
    }

    func mapView(
        _ mapView: MKMapView,
        regionDidChangeAnimated animated: Bool
    ) {
        print("??", mapView.layer.position)
    }
}

#Preview("Main") {
    MainAppScreenPreview()
}
