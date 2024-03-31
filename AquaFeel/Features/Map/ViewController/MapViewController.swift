//
//  MapViewController.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/1/24.
//
/*

 mapView.settings.scrollGestures = false
 mapView.settings.zoomGestures = false
 mapView.settings.tiltGestures = false
 mapView.settings.rotateGestures = false
 */

import GoogleMaps
import GoogleMapsUtils
import SwiftUI
import UIKit
import UIKit.UIGestureRecognizerSubclass
struct MapMenuItem {
    var title: String
    var image: String

    var imageOff: String = ""
    var color: UIColor
    var action: ((MapButton) -> Void)?
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

func calculateMarkersAround(markers: inout [GMSMarker], center: CLLocationCoordinate2D, count: Int, distance: CLLocationDistance) {
    // Convert distance to meters
    let radiusMeters = distance * 1.0

    // Calculate the angle between each point
    let angleSeparation = 360.0 / Double(markers.count)

    // Loop to generate each coordinate
    for i in 0 ..< markers.count {
        print(i)
        // Calculate the current angle
        let currentAngle = Double(i) * angleSeparation

        // Convert angle to radians
        let radians = currentAngle * .pi / 180.0

        // Calculate the latitude and longitude of the new coordinate
        let newLatitude = center.latitude + radiusMeters * cos(radians) / 111139.0
        let newLongitude = center.longitude + radiusMeters * sin(radians) / (111139.0 * cos(center.latitude))

        let newPosition = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
        print(newPosition)
        markers[i].position = newPosition
    }
}

func calculateMarkersAround1(markers: inout [GMSMarker], center: CLLocationCoordinate2D,  distance: CLLocationDistance, manager: GMUClusterManager) {
    // Calcular el ángulo entre cada marcador
    let angleStep = 360.0 / Double(markers.count)

    // Calcular las posiciones de los marcadores adicionales
    for i in 0 ..< markers.count {
        
       
        
        let angle = angleStep * Double(i)
        let x = distance * cos(angle * .pi / 180.0)
        let y = distance * sin(angle * .pi / 180.0)

        let newLatitude = center.latitude + (y / 111111.0)
        let newLongitude = center.longitude + (x / (111111.0 * cos(center.latitude * .pi / 180.0)))
        
        let newPosition = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
        //markers[i].map = nil
        manager.remove(markers[i])
        markers[i].position = newPosition
        markers[i].groundAnchor = CGPoint(x: 0.5, y: 0.5)
        manager.add(markers[i])
    }
}

func calculateMarkersAround2(markers: inout [GMSMarker], center: CLLocationCoordinate2D, count: Int, distance: CLLocationDistance) {
    // var markers = [GMSMarker]()

    // Calcular el ángulo entre cada marcador
    let angleStep = 360.0 / Double(count)

    // Calcular las posiciones de los marcadores adicionales
    for i in 0 ..< markers.count {
        let angle = angleStep * Double(i)
        let x = distance * cos(angle * .pi / 180.0)
        let y = distance * sin(angle * .pi / 180.0)

        let newLatitude = center.latitude + (y / 111111.0)
        let newLongitude = center.longitude + (x / (111111.0 * cos(center.latitude * .pi / 180.0)))

        let newPosition = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
        markers[i].position = newPosition
        // markers[i].map = nil
        print(newLatitude, newLongitude)
        // markers.append(marker)
    }

    // return markers
}



class MapButton: UIButton {
    enum ButtonState {
        case normal
        case active
    }

    // Properties
    private let image: String
    private let activeImage: String
    private let color: UIColor
    var action: ((MapButton) -> Void)?

    var currentState: ButtonState = .active

    let button: UIButton

    // Optional action closure for button press

    // Initializer with image name, color, and optional action closure
    init(image: String, offImage: String, color: UIColor, currentState: ButtonState = .normal, action: ((MapButton) -> Void)? = nil) {
        self.image = image
        activeImage = offImage
        self.color = color
        self.currentState = .normal
        self.action = action

        // Initialize UIButton
        button = UIButton(type: .system)
        super.init(frame: .zero) // Call superclass initializer with zero frame
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Function to configure the button's appearance and behavior
    private func setupButton() {
        let size: CGFloat = 40.0

        // Configure button image and color
        // let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        // let buttonImage = UIImage(systemName: image, withConfiguration: symbolConfiguration)
        // button.setImage(buttonImage, for: .normal)
        button.tintColor = color

        // Enable user interaction
        button.isUserInteractionEnabled = true

        // Set button appearance (background, corner radius, border)
        button.backgroundColor = .white
        button.layer.cornerRadius = 0.5 * size
        button.layer.borderWidth = 0.5
        button.layer.borderColor = color.cgColor

        // Add target for button press (optional action execution)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        // Add button as subview
        addSubview(button)

        // Set button constraints (optional, adjust as needed)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        updateButton()
    }

    // Function to handle button press, update state, and call optional action
    @objc func buttonPressed() {
        currentState = currentState == .normal ? .active : .normal
        updateButton()
        action?(self) // Optionally execute the action closure with the button
    }

    // Function to update button image based on current state
    func updateButton() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        var image = UIImage(systemName: image, withConfiguration: symbolConfiguration)
        if activeImage != "" && currentState == .active {
            image = UIImage(systemName: activeImage, withConfiguration: symbolConfiguration)
        }

        button.setImage(image, for: .normal)
    }
}

enum MapMode {
    case normal
    case mark
    case polygon
}

struct MapViewState {
    var leads: [LeadModel]
    var path: GMSMutablePath
    var mode: Bool
    var leadSelected: LeadModel?
}

// var clusterManager: GMUClusterManager!
// var c:MapViewCoordinator!

// var start: Bool = false

class AquaFeelModel: ObservableObject {
    @Published var path = GMSMutablePath()
    @Published var mode = false
    @Published var newLead = false
    @Published var newPosition: CLLocationCoordinate2D?
}

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

protocol MapDraw {
    func play()
    func stop()
    func pause()
    func get()
    func reset()
}

protocol ResettableView {
    func resetPieces(_: DragDropGestureRecognizer)
}

class MapViewController: UIViewController, GMSMapViewDelegate,  GMUClusterRendererDelegate, UIGestureRecognizerDelegate, ResettableView, GMUClusterManagerDelegate {
    let map = GMSMapView()
    
    // var mode:Bool = false
    var mode: Binding<Bool>?
    
    var newLead: Binding<Bool>?
    
    // var path: GMSMutablePath?
    
    var path: Binding<GMSMutablePath>?
    var draw: Draw?
    var drawMark: DrawMark?
    var newPath = GMSMutablePath()
    
    var onPlay = false
    
    var drawing = false
    var firstPoint: CLLocationCoordinate2D?
    
    var location: CLLocationCoordinate2D?
    
    // @Binding var path:GMSMutablePath
    // @Binding var mode: Bool
    var leadSelected: LeadModel?
    var markerSelected: Binding<LeadModel?>
    var leads: Binding<[LeadModel]>
    
    private var drawPlay = false
    private var markPlay = false
    
    var started = false
    
    var mapMode = MapMode.normal
    
    var lastButton: MapButton?
    var newPosition: Binding<CLLocationCoordinate2D?>
    
    var lastMarker: Binding<GMSMarker?>
    
    var markerGroups: [String: [GMSMarker]] = [:]
    var playState: Bool = false {
        didSet {
            print("playState")
            updatePlayButtonImage()
        }
    }
    
    init(markerSelected: Binding<LeadModel?>, location: CLLocationCoordinate2D?, leads: Binding<[LeadModel]>, newPosition: Binding<CLLocationCoordinate2D?>, lastMarker: Binding<GMSMarker?>) {
        self.markerSelected = markerSelected
        self.location = location
        self.leads = leads
        self.newPosition = newPosition
        self.lastMarker = lastMarker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    public lazy var clusterManager: GMUClusterManager = {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        // iconGenerator.borderColor = .black // Cambiar el color del borde a negro
        // iconGenerator.borderWidth = 1.0 // Establecer el ancho del borde
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        
        return GMUClusterManager(map: self.map, algorithm: algorithm, renderer: renderer)
    }()
    */
    private var clusterManager1: GMUClusterManager!
    
    override func loadView() {
        super.loadView()
        
        var longitude = -74.0060 // -74.0060 // -122.008972 //-122.008972
        var latitude = 40.7128 // 40.7128 // 39.2750209// 37.33464379999999
        
        if let location = location {
            longitude = location.longitude
            latitude = location.latitude
        }
        // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
        map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 2.0)
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        
        draw = Draw(map: map)
        drawMark = DrawMark(map: map) { p in
            
            self.newPosition.wrappedValue = p
            self.doPlay(.normal)
            if let newLead = self.newLead {
                newLead.wrappedValue = true
            }
        }
        
        // self.myDraw()
        
        // draw = Draw11(target: self,map: map)
        // draw?.play()
        // map.addGestureRecognizer(draw.drawGesture)
        // self.play()
        // draw.play2(drawGesture: UIPanGestureRecognizer(target: self, action: #selector(START)))
        // x = MapViewDelegateHandler(self)
        // map.delegate = draw  //x//self
        // map.isUserInteractionEnabled = false
        // map.settings.allowScrollGesturesDuringRotateOrZoom = false
        
        /*
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
         //map.addTarget(self, action: #selector(toggleGestures2), for: .touchUpInside)
         
         map.addGestureRecognizer(tapGestureRecognizer)
         
         let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draw._startDraw))
         map.addGestureRecognizer(panGestureRecognizer)
         
         let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
         map.addGestureRecognizer(gestureRecognizer)
         */
        // play()
        // map.delegate = self
        
        // map.delegate = self
        view = map
        /*
         
         map.settings.setAllGesturesEnabled(true)
         
         let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(resetPieces(_:)))
         view.addGestureRecognizer(resetGestureRecognizer)
         
         //resetGestureRecognizer.delegate = self
         
         resetGestureRecognizer.cancelsTouchesInView = false
         
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size: CGFloat = 40.0
        let items = [
            /* MapMenuItem(title: "a", image: "info.bubble", color: .darkGray) { _ in
             
             print("aaaa")
             // self.stop()
             // line.horizontal.3.decrease.circle
             self.showLeadsOptions()
             }, */
            // MapMenuItem(title: "b", image: "magnifyingglass", color: .darkGray),
            
            /* MapMenuItem(title: "c", image: "app.connected.to.app.below.fill", color: .darkGray) { _ in
             
             }, */
            MapMenuItem(title: "d", image: "pin.fill", imageOff: "eraser.fill", color: .darkGray) { button in
                if let last = self.lastButton, self.lastButton != button {
                    last.currentState = .normal
                    last.updateButton()
                }
                /* let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
                 var image = UIImage(systemName: "pin.fill", withConfiguration: symbolConfiguration)
                 if self.mapMode == .mark {
                 image = UIImage(systemName: "eraser.fill", withConfiguration: symbolConfiguration)
                 }
                 
                 button.setImage(image, for: .normal)
                 // self.setMarkPlay() */
                if self.mapMode != .mark {
                    self.doStop()
                    self.doPlay(.mark)
                    // button.currentState = .on
                } else {
                    self.doStop()
                }
                self.lastButton = button
                
            },
            MapMenuItem(title: "d", image: "hand.draw.fill", imageOff: "eraser.fill", color: .darkGray) { button in
                if let last = self.lastButton, self.lastButton != button {
                    last.currentState = .normal
                    last.updateButton()
                }
                /* let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
                 var image = UIImage(systemName: "hand.draw.fill", withConfiguration: symbolConfiguration)
                 if !self.drawPlay {
                 image = UIImage(systemName: "eraser.fill", withConfiguration: symbolConfiguration)
                 }
                 
                 button.setImage(image, for: .normal) */
                if self.mapMode != .polygon {
                    self.doStop()
                    self.doPlay(.polygon)
                    // button.currentState = .on
                } else {
                    self.doStop()
                }
                self.lastButton = button
                
            },
        ]
        let stackView = UIStackView()
        // stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // Configuración del stack view
        stackView.axis = .vertical
        stackView.alignment = .leading
        // stackView.distribution = .fill
        // stackView.backgroundColor = .magenta
        stackView.spacing = 20 // Puedes ajustar el espaciado según tus necesidades
        stackView.isLayoutMarginsRelativeArrangement = true
        // stackView.isLayoutMarginsRelativeArrangement = true
        // stackView.translatesAutoresizingMaskIntoConstraints = true
        stackView.clipsToBounds = true
        
        items.forEach { item in
            let button = MapButton(image: item.image, offImage: item.imageOff, color: item.color, currentState: .normal, action: item.action)
            button.widthAnchor.constraint(equalToConstant: size).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            
            // let gestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
            // button.addGestureRecognizer(gestureRecognizer)
            /* if let action = item.action {
             print(9.1)
             button.addAction(UIAction(handler: { _ in
             print(9)
             action(button)
             }), for: .touchUpInside)
             }else{
             print(10)
             //button.addTarget(self, action: #selector(defaultTouche), for: .touchUpInside)
             button.addAction(UIAction(handler: { _ in
             print("nothing")
             }), for: .touchUpInside)
             }
             */
            stackView.addArrangedSubview(button)
        }
        
        /*
         items.forEach{ item in
         let button = UIButton(type: .system)
         let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
         let trashImage = UIImage(systemName: item.image, withConfiguration: symbolConfiguration)
         button.setImage(trashImage, for: .normal)
         //button.setImage(UIImage(systemName: item.image2, withConfiguration: symbolConfiguration), for: .selected)
         
         // Ajustar el color del símbolo
         button.tintColor = item.color
         button.isUserInteractionEnabled = true
         // Ajustar la apariencia del botón para que tenga un fondo circular grande y un borde
         button.backgroundColor = .white
         button.layer.cornerRadius = 0.5 * size // Tamaño del círculo (ajustar según sea necesario)
         button.layer.borderWidth = 0.5  // Ancho del borde
         button.layer.borderColor = item.color.cgColor  // Color del borde
         
         // Configuración de acciones y restricciones
         //button.addTarget(self, action: #selector(toggleGestures), for: .touchUpInside)
         stackView.addArrangedSubview(button)
         
         // Aplicar restricciones al botón
         button.widthAnchor.constraint(equalToConstant: size).isActive = true
         button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
         
         if let action = item.action {
         
         button.addAction(UIAction(handler: { _ in
         
         action(button)
         }), for: .touchUpInside)
         }else{
         
         //button.addTarget(self, action: #selector(defaultTouche), for: .touchUpInside)
         button.addAction(UIAction(handler: { _ in
         print("nothing")
         }), for: .touchUpInside)
         }
         let gestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
         //gestureRecognizer.delegate = self
         button.addGestureRecognizer(gestureRecognizer)
         stackView.addArrangedSubview(button)
         playButton?.append(button)
         
         }*/
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            // stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 150),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            // stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
        
        
        let renderer = GMUDefaultClusterRenderer(mapView: map, clusterIconGenerator: iconGenerator)
        let clusterRendererDelegate = CustomClusterRendererDelegate()
        renderer.maximumClusterZoom = 20
        
        renderer.delegate = self
        // clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager1 = GMUClusterManager(map: map, algorithm: algorithm, renderer: renderer)
        // Register self to listen to GMSMapViewDelegate events.
        //clusterManager1.setMapDelegate(self) // (context.coordinator)//(c)
        clusterManager1.setDelegate(self, mapDelegate: self)
        
        
        clusterManager1.cluster()
    }
    
    func start() {
        print("start")
        generateClusterItems(manager: clusterManager1)
    }
    
    
    func randomFloat(min: Float, max:Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    private func generateClusterItems(manager: GMUClusterManager) {
        let leads = leads.wrappedValue
        /* guard let leads = leads.wrappedValue else {
         
         // Manejar el caso cuando leads es nil
         return
         }
         */
        // map.clear()
        manager.clearItems()
        markerGroups = [:]
        print("markerGroups generateClusterItems: \(leads.count)")
        
        
        for leadModel in leads {
            // print( leadModel.first_name ?? "-/n")
            if var latitude = Double(leadModel.latitude),
               var longitude = Double(leadModel.longitude) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                // print(truncateCoordinatesStr( marker.position, toDecimals: 5))
                var circleIconView =
                // CircleIconView(systemName: "trash", color: .red)
                getUIImage(name: leadModel.status_id.name)
                let truncatedCoordinate = truncateCoordinatesStr(position, toDecimals: 6)
                print("truncatedCoordinate : ", truncatedCoordinate)
                if var existingMarkers = markerGroups[truncatedCoordinate] {
                    
                    //existingMarkers.append(marker)
                    print("si existe ... . . . . .")
                    markerGroups[truncatedCoordinate]?.append(marker)
                    
                } else {
                    markerGroups[truncatedCoordinate] = [marker]
                }
                manager.add(marker)
                if markerGroups[truncatedCoordinate]?.count ?? 0 > 1 {
                    
                    guard let firstPosition = markerGroups[truncatedCoordinate]?.first?.position else{
                        return
                    }
                    
                    
                    let point = truncateCoordinates(position, toDecimals: 6)
                    
                    print("markerGroups", truncatedCoordinate, markerGroups[truncatedCoordinate]?.count)
                    
                    print("markerGroups leadModel.first_name", leadModel.first_name)
                    
                    circleIconView = getUIImage(name: "none")
                    let variation = (randomFloat(min: 0.0, max: 2.0) - 0.5) / 1500
                    latitude = latitude + Double(variation)
                    longitude = longitude + Double(variation)
                    //markerGroups[truncatedCoordinate]?.first?.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    //manager.remove(markerGroups[truncatedCoordinate]!.first!)
                    //marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    //circleIconView = getUIImage(name: "none")
                    // marker.position = CLLocationCoordinate2D(latitude: latitude + 0.0005, longitude: longitude)
                    
                   
                    let  circle = GMSCircle(position: point, radius: 20.0)
                    
                    circle.map = map
                    
                    
                    
                    
                   calculateMarkersAround1(markers: &markerGroups[truncatedCoordinate]!, center: point, distance: 20, manager: manager)
                    
                    
                    for marker in markerGroups[truncatedCoordinate]! {
                        // Crear la ruta con dos puntos: el punto central y la posición del marcador
                        let path = GMSMutablePath()
                        path.add(point)
                        path.add(marker.position)
                        
                        // Crear la línea
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = .blue
                        polyline.strokeWidth = 2.0
                        
                        // Mostrar la línea en el mapa
                        polyline.map = map
                    }
                }
                
               
               
                
               
                
                // marker.title = leadModel.first_name
                marker.isTappable = true
                // marker.userData = ["name":  leadModel.id ]
                marker.userData = leadModel
                
                circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)
                
                if true && false {
                    let circleLayer = CALayer()
                    let circleSizeIncrease: CGFloat = 28 // Ajusta el tamaño del aumento según tus necesidades
                    circleLayer.bounds = CGRect(x: 0, y: 0, width: circleIconView.bounds.width + circleSizeIncrease, height: circleIconView.bounds.height + circleSizeIncrease)
                    circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
                    circleLayer.cornerRadius = circleLayer.bounds.width / 2
                    // circleLayer.backgroundColor = UIColor.white.cgColor
                    circleLayer.borderWidth = 6.0 // Grosor del borde del círculo
                    circleLayer.borderColor = UIColor.white.cgColor // Color del borde del círculo
                    circleIconView.layer.addSublayer(circleLayer)
                } else {
                    // Crea un círculo rojo
                    let circleLayer = CALayer()
                    circleLayer.bounds = circleIconView.bounds
                    circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
                    circleLayer.cornerRadius = circleIconView.bounds.width / 2
                    // circleLayer.backgroundColor = UIColor.red.cgColor
                    circleLayer.borderWidth = 0.0 // Grosor del borde del círculo
                    circleLayer.borderColor = UIColor.black.cgColor // Color del borde del círculo
                    
                    // Añade el círculo rojo a tu imagen
                    circleIconView.layer.addSublayer(circleLayer)
                }
                
                /*
                 let circleIconView = StatusUIView(status: .nho)
                 circleIconView.frame = CGRect(x: 120, y: 120, width: 50, height: 50)
                 */
                
                
                marker.iconView = circleIconView
                
                
                
                
            }
            
        }
        manager.cluster()
        // manager.cluster()
        print("ready ClusterItems: \(manager.clusterRequestCount())")
        /*
         let extent = 0.2
         for _ in 1...kClusterItemCount {
         let lat = kCameraLatitude + extent * randomScale()
         let lng = kCameraLongitude + extent * randomScale()
         let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
         let marker = GMSMarker(position: position)
         //manager.add(marker)
         }
         */
    }
    
    func doPlay(_ mode: MapMode) {
        switch mode {
        case .normal:
            return
        case .mark:
            startMark()
        case .polygon:
            play()
        }
    }
    
    func doStop() {
        switch mapMode {
        case .normal:
            return
        case .mark:
            stopMark()
        case .polygon:
            stop()
        }
    }
    
    func setPlay() {
        onPlay.toggle()
        if onPlay {
            play()
        } else {
            stop()
        }
    }
    
    func setMarkPlay() {
        markPlay.toggle()
        if markPlay {
            startMark()
        } else {
            stopMark()
        }
    }
    
    func startMark() {
        print("map.delegate = drawMark")
        mapMode = .mark
        map.delegate = drawMark
    }
    
    func stopMark() {
        print("map.delegate = self")
        drawMark?.stop()
        map.delegate = self
        mapMode = .normal
    }
    
    func play() {
        print("play 2024()")
        map.settings.setAllGesturesEnabled(false)
        
        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(resetPieces(_:)))
        map.addGestureRecognizer(resetGestureRecognizer)
        
        // resetGestureRecognizer.delegate = self
        
        resetGestureRecognizer.cancelsTouchesInView = false
        drawPlay = true
        mapMode = .polygon
    }
    
    func stop() {
        map.settings.setAllGesturesEnabled(true)
        draw?.stop()
        drawPlay = false
        mapMode = .normal
    }
    
    func showLeadsOptions() {
        if let path2 = draw?.path2 {
            path?.wrappedValue = GMSMutablePath(path: path2)
        }
        
        // print("New path count in ended ", newPath.count())
        /*
         for index in 0..<newPath.count() {
         let coordinate = newPath.coordinate(at: index)
         print("Latitud: \(coordinate.latitude), Longitud: \(coordinate.longitude)")
         }
         */
        // path?.wrappedValue = newPath
        
        if let mode = mode {
            mode.wrappedValue = true
        }
    }
    
    func play1() {
        print("play")
        
        map.settings.setAllGesturesEnabled(false)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(startDraw))
        map.addGestureRecognizer(panGestureRecognizer)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        map.addGestureRecognizer(gestureRecognizer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        view.addGestureRecognizer(longPressGesture)
        
        let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
        view.addGestureRecognizer(hover)
    }
    
    @objc
    func resetPieces(_ gesture: DragDropGestureRecognizer) {
        let location = gesture.location(in: view)
        if let tappedView = view.hitTest(location, with: nil) {
            // print("no Se tocó la mapa: \(tappedView.self)")
            
            if tappedView.self is UIButton {
                // print("Se tocóUN Boton \(tappedView.self)")
                return
            }
            
            // print("layer ", tappedView.layer, self.view)
            if tappedView == view {
                // print("Se tocó la vista del ViewController: MISMO")
                // Realiza acciones específicas para tu ViewController
                return
            }
        }
        
        switch gesture.state {
        case .began:
            // Inicia el dibujo
            
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            // print(coordinate.latitude)
            // draw?.add(coordinate: coordinate)
            
            firstPoint = coordinate
            // print("Began drawing")
        case .changed:
            // Procesa los puntos tocados para dibujar
            // let touchedPoints = gesture.touchedPoints
            // Implementa tu lógica de dibujo aquí
            // print("Changed drawing: \(touchedPoints)")
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            if !drawing, let firstPoint = firstPoint {
                draw?.add(coordinate: firstPoint)
            }
            drawing = true
            // print(coordinate.latitude)
            draw?.add(coordinate: coordinate)
            // print("Changed drawing: (touchedPoints)")
        case .ended:
            // Finaliza el dibujo
            
            if drawing {
                draw?.bye()
            } else {
                showLeadsOptions()
            }
            drawing = false
            /*
             newPath = GMSMutablePath(path: draw?.path2 ?? GMSMutablePath())
             print(newPath.count())
             print("New path count in ended state:", newPath.count())
             
             path?.wrappedValue = newPath
             */
            
            // newPath = GMSMutablePath(path: self.draw?.path2 ?? GMSMutablePath())
            
            // newPath = GMSMutablePath()
            // newPath.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
            // newPath.add(CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
            // newPath.add(CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
            
            // print(".ended:", self.newPath.count())
            if let path2 = draw?.path2 {
                // print("yes \(path2.count())")
                path?.wrappedValue = GMSMutablePath(path: path2)
                newPath = GMSMutablePath(path: path2)
            }
            
            /*
             
             if let path = path?.wrappedValue {
             for index in 0..<path.count() {
             let coordinate = path.coordinate(at: index)
             print("\(index) => Latitud: \(coordinate.latitude), Longitud: \(coordinate.longitude)")
             }
             }
             
             for index in 0..<newPath.count() {
             let coordinate = newPath.coordinate(at: index)
             print("\(index) Latitud: \(coordinate.latitude), Longitud: \(coordinate.longitude)")
             }
             */
            /*
             if let path = path {
             print("Count: ")
             print(draw?.path2.count())
             path.wrappedValue = GMSMutablePath(path: draw?.path2 ?? GMSMutablePath()) //draw?.path2 ?? GMSMutablePath()
             }
             */
            // print("Ended drawing")
        default:
            break
        }
    }
    
    /*
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     print("touchesBegan 1.00")
     
     return
     
     }
     */
    /*
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     super.touchesMoved(touches, with: event)
     print("touchesMoved")
     
     if let touch = touches.first {
     let tapPoint = touch.location(in: map)
     let coordinate = map.projection.coordinate(for: tapPoint)
     
     print(coordinate.latitude)
     draw?.add(coordinate: coordinate)
     }
     
     //state = .changed
     }
     
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
     super.touchesEnded(touches, with: event)
     draw?.reset()
     
     }
     
     */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("gestureRecognizer .. gestureRecognizer .. gestureRecognizer")
        return true
    }
    
    @objc func startDraw(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("handlePanGesture")
        if gestureRecognizer.state == .ended {
            print("Bye.................")
            // draw?.bye()
        } // Actualiza la ruta que el usuario está dibujando.
        if gestureRecognizer.state == .began {
            print("hello")
            let tapPoint = gestureRecognizer.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            draw?.add(coordinate: coordinate)
            
        } else if gestureRecognizer.state == .changed {
            let tapPoint = gestureRecognizer.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            // Acciones a realizar cuando se toca el mapa
            // print("Tocaste en la coordenada: \(coordinate.latitude), \(coordinate.longitude)")
            
            draw?.add(coordinate: coordinate)
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("xxxxxxxxxx")
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: view)
            // Aquí tienes la primera posición donde el dedo toca la pantalla
            print("Posición inicial: \(location)")
        } else if gestureRecognizer.state == .changed {
            // Aquí puedes manejar el movimiento del dedo si es necesario
        } else if gestureRecognizer.state == .ended {
            // Aquí puedes manejar el evento de liberación del dedo
        }
    }
    
    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        print("hovering")
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer? = nil) -> Bool {
        print("handleTap")
        
        // Obtenga la ubicación del toque
        // let location = gestureRecognizer.location(in: mapView)
        // Coordine la ubicación del toque
        // let coordinate = mapView.projection.coordinate(for: location)
        // Implemente la acción deseada
        // print("Tocado en la coordenada: \(coordinate)")
        
        // En el método gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:) del UIGestureRecognizer, devuelve true para permitir que el usuario dibuje sobre el mapa mientras interactúa con otros elementos de la interfaz de usuario.
        return false
    }
    
    var playButton: [UIButton]?
    private func updatePlayButtonImage() {
        print("updatePlayButtonImage")
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let imageName = playState ? "house" : "house"
        let trashImage = UIImage(systemName: imageName, withConfiguration: symbolConfiguration)
        
        // playButton?.first?.setImage(trashImage, for: .normal)
    }
    
    @objc func toggleGestures() {
        map.miTest()
        print("x")
        // start = true
        map.settings.setAllGesturesEnabled(false)
        // map.settings.scrollGestures = false
        // button.setTitle(true ? "Disable Gestures" : "Enable Gestures", for: .normal)
    }
    
    @objc func toggleGestures2() {
        print("y")
        // start = false
        map.settings.setAllGesturesEnabled(true)
        // map.settings.scrollGestures = true
        // button.setTitle(true ? "Disable Gestures" : "Enable Gestures", for: .normal)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("handlePanGesture")
        if gestureRecognizer.state == .ended {
        } // Actualiza la ruta que el usuario está dibujando.
        if gestureRecognizer.state == .began {
        } else if gestureRecognizer.state == .changed {
            let tapPoint = gestureRecognizer.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            // Acciones a realizar cuando se toca el mapa
            print("Tocaste en la coordenada: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }
    
    // Cuando el usuario deja de dibujar, agrega la ruta al mapa.
    @objc func handlePanGestureEnded(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("BBBBBB")
        if gestureRecognizer.state == .ended {
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapOverlay coordinate: CLLocationCoordinate2D) {
        print("didTapOverlay0.0")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("arenita playita 0.0")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("didLongPressAt")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("willMove")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        /* print(".")
         let latitude = position.target.latitude
         let longitude = position.target.longitude
         
         print("Posición del usuario cambiada a (Latitud: \(latitude), Longitud: \(longitude))")
         
         */
        // Puedes realizar acciones adicionales basadas en el movimiento del usuario aquí
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        
        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            
            print("......Did tap cluster")
            return false
        }
        
        print(".....Did tap marker")
        
        /* if let userData = marker.userData as? [String:String]{
         print(userData["name"] ?? "")
         self.markerSelected.wrappedValue = LeadModel(id: userData["name"] ?? "")
         } */
        
        // marker.iconView?.backgroundColor = .black
        
        if let last = lastMarker.wrappedValue {
            if let sublayers = last.iconView?.layer.sublayers {
                if let lastLayer = sublayers.last {
                    // Modificar la capa recién agregada
                    // lastLayer.cornerRadius = (marker.iconView?.bounds.width ?? 0) / 2
                    lastLayer.borderWidth = 0.0
                }
            }
        }
        
        lastMarker.wrappedValue = marker
        
        if let userData = marker.userData as? LeadModel {
            // print(userData["name"] ?? "")
            markerSelected.wrappedValue = userData
        }
        return false
    }
    
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
     
     }
     */
    
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        print(1234564)
        
       
        
        if let marker = object as? GMSMarker {
            
            print(55555555)
            // Devuelve un marcador personalizado si el objeto es un marcador
            let customMarker = GMSMarker()
            customMarker.position = marker.position
            customMarker.title = "Marcador Personalizado"
            //customMarker.icon = UIImage(named: "custom_marker_icon") // Icono personalizado para el marcador
            
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            let symbolImage = UIImage(systemName: "star.fill", withConfiguration: symbolConfiguration)
            
            // Crea una imagen personalizada a partir del símbolo
            let customImage = symbolImage?.withTintColor(.blue) // Puedes ajustar el color según sea necesario
            
            // Asigna la imagen personalizada como icono del marcador
            customMarker.icon = customImage
            
            return customMarker
        }
        // Devuelve nil si el objeto no es un marcador
       
        return nil
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker){
        print("renderer .. renderer")
    }
    
    func renderer(_ renderer: GMUClusterRenderer, didRenderMarker marker: GMSMarker) {
        print("hello hello")
    }
    
    func renderer(_ renderer: GMUClusterRenderer, didRenderCluster cluster: GMUCluster, animated: Bool) {
        // Aquí puedes realizar acciones después de que se renderiza un clúster, como mostrar un mensaje o actualizar la interfaz de usuario
        print("Cluster renderizado: \(cluster)")
    }
    
    func renderer(_ renderer: GMUClusterRenderer, didRenderMarker cluster: GMUCluster, animated: Bool) {
        // Aquí puedes realizar acciones después de que se renderiza un clúster, como mostrar un mensaje o actualizar la interfaz de usuario
        print("Cluster renderizado: \(cluster)")
    }


    
    @objc(clusterManager:didTapCluster:) func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        print("tap cluster")
        return false
    }
    
    @objc(clusterManager:didTapClusterItem:) func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        print("tap cluster item")
        return false
    }
}


class CustomClusterRendererDelegate: NSObject, GMUClusterRendererDelegate {
    
    // Método que se llama después de que se renderiza un clúster en el mapa
    func renderer(_ renderer: GMUClusterRenderer, didRenderCluster cluster: GMUCluster, animated: Bool) {
        // Aquí puedes realizar acciones después de que se renderiza un clúster, como mostrar un mensaje o actualizar la interfaz de usuario
        print("Cluster renderizado: \(cluster)")
    }
}




struct MapViewControllerBridge: UIViewControllerRepresentable {
    @ObservedObject var aqua: AquaFeelModel

    @Binding var leads: [LeadModel]

    @Binding var path: GMSMutablePath
    @Binding var mode: Bool
    @Binding var newLead: Bool
    @Binding var leadSelected: LeadModel?
    @Binding var contador: Int
    @Binding var lastMarker: GMSMarker?
    var location: CLLocationCoordinate2D

    func makeUIViewController(context: Context) -> MapViewController {
        let uiViewController = MapViewController(markerSelected: $leadSelected, location: location, leads: $leads, newPosition: $aqua.newPosition, lastMarker: $lastMarker)

        uiViewController.mode = $mode
        uiViewController.newLead = $newLead
        uiViewController.path = $path
        uiViewController.markerSelected = $leadSelected
        uiViewController.map.delegate = uiViewController
        uiViewController.leads = $leads

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        print("updateUIViewController ........", leads.count, " vs. ", uiViewController.leads.wrappedValue.count)

        // if uiViewController.leads.wrappedValue.count != leads.count {
        if !leads.isEmpty {
            if leads != uiViewController.leads.wrappedValue || !uiViewController.started {
                DispatchQueue.main.async {
                    uiViewController.started = true
                    uiViewController.leads = $leads

                    uiViewController.start()
                }
            }
        }
    }
}

struct LeadMap: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    @EnvironmentObject var store: MainStore<UserData>
    // @EnvironmentObject var loginManager: ProfileManager

    // @State var mode = false
    @State var showSettings = true
    // @State var path = GMSMutablePath()
    @StateObject var aqua = AquaFeelModel()
    @ObservedObject var manager: LeadManager
    // @StateObject var manager = LeadManager(autoLoad: true, limit: 2000, maxLoads: 510) // LeadViewModel(first_name: "Juan", last_name: "")
    // @State var selected:LeadModel? = LeadModel()
    @State var info = false

    // var placeManager = LocationViewModel()

    @State var showFilter = false

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    // @StateObject var lead = LeadManager()

    // @StateObject var user = UserManager()

    @Environment(\.scenePhase) private var scenePhase
    @State var contador = 0
    var location: CLLocationCoordinate2D
    @State var lead: LeadModel = LeadModel()
    @StateObject private var placeViewModel = PlaceViewModel()
    @State var lastMarker: GMSMarker? = nil
    // @State var updated = false
    var body: some View {
        MapViewControllerBridge(aqua: aqua, leads: $manager.leads, path: $aqua.path, mode: $aqua.mode, newLead: $aqua.newLead, leadSelected: $manager.selected, contador: $contador, lastMarker: $lastMarker, location: location)

            .edgesIgnoringSafeArea(.all)
            // .environmentObject($lead.leads)
            .sheet(isPresented: $aqua.mode) {
                PathOptionView(profile: profile, leads: $manager.leads, path: $aqua.path, leadManager: manager, updated: $updated)
                    .presentationDetents([.fraction(0.35), .medium, .large])
                    .presentationContentInteraction(.scrolls)
            }
            .sheet(isPresented: $aqua.newLead) {
                CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, updated: .constant(false)) { result in
                    if result {
                        // manager.leads.append(lead)
                    }
                }.onAppear {
                    placeViewModel.getPlaceDetailsByCoordinates(latitude: aqua.newPosition?.latitude ?? 0, longitude: aqua.newPosition?.longitude ?? 0)
                }.onReceive(placeViewModel.$selectedPlace) { x in

                    lead = placeViewModel.decode(placeDetails: x, leadAddress: lead)
                }
            }

            .sheet(isPresented: $info) {
                // LeadDetailView(lead: lead.selected ?? LeadModel())
                NavigationStack {
                    CreateLead(profile: profile, lead: Binding<LeadModel>(
                        get: { manager.selected ?? LeadModel() },
                        set: { manager.selected = $0 }
                    ), mode: 0, manager: manager, updated: $updated) { _ in
                        print("on Saving")
                    }
                }

                .presentationDetents([.fraction(0.2), .medium, .large])
                .presentationContentInteraction(.scrolls)
            }

            .sheet(isPresented: $showFilter) {
                FilterOption(filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                    // lead.reset()
                    manager.resetFilter()
                    manager.runLoad()
                }
                .onAppear {
                    contador += 10

                    // lead2.statusAll()
                }

                Button(action: {
                    // Acción para mostrar la ventana modal con filtros
                    showFilter.toggle()
                }) {
                    Text("Close")
                    /* Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                     .foregroundColor(.blue)
                     .font(.system(size: 20)) */
                }
                .padding()
            }

            .onDisappear {
                manager.selected = nil
            }
            .onAppear {
                DispatchQueue.main.async {
                    manager.selected = nil
                }

                manager.initFilter { _, _ in

                    print("completation loadStatus")
                }
                /*
                 if let leadFilters = loginManager.info.leadFilters {

                     manager.leadFilter = leadFilters
                 }

                  */

                // manager.token = loginManager.token
                // manager.role = loginManager.role
                // manager.user = loginManager.id

                /*
                 store.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE"

                 manager.token = store.token
                 manager.role = store.role
                 manager.user = store.id

                 if manager.leads.isEmpty {
                     manager.reset()
                     manager.runLoad()
                 }

                 print(":::::::", store.token)
                 */
            }

            .onReceive(manager.$leadFilter) { filter in

                DispatchQueue.main.async {
                    profile.info.leadFilters = filter
                }
            }

            .onReceive(manager.$selected) { selected in

                if selected != nil {
                    info = true
                }
            }

            .onChange(of: info) { _ in
                print("manager.leads.count", manager.leads.count)
            }

            .onChange(of: updated) { value in
                if value {
                    print("search() 1.1")
                    // manager.search()
                }
                // updated = false
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .onChange(of: info) { info in
                print("last marker", info)
                print(lastMarker)

                if let sublayers = lastMarker?.iconView?.layer.sublayers {
                    if let lastLayer = sublayers.last {
                        // Modificar la capa recién agregada
                        // lastLayer.cornerRadius = (marker.iconView?.bounds.width ?? 0) / 2
                        if info {
                            lastLayer.borderWidth = 3.0
                        } else {
                            lastLayer.borderWidth = 0.0
                        }
                    }
                }
            }

            .onChange(of: lastMarker) { _ in
                print("last marker", info)
                print(lastMarker)

                if let sublayers = lastMarker?.iconView?.layer.sublayers {
                    if let lastLayer = sublayers.last {
                        // Modificar la capa recién agregada
                        // lastLayer.cornerRadius = (marker.iconView?.bounds.width ?? 0) / 2
                        if info {
                            lastLayer.borderWidth = 3.0
                        } else {
                            lastLayer.borderWidth = 0.0
                        }
                    }
                }
            }

        /* if info {
             NavigationStack {
                 CreateLead(profile: profile, lead: Binding<LeadModel>(
                     get: { manager.selected ?? LeadModel() },
                     set: { manager.selected = $0 }
                 ), mode: 0, manager: manager) { _ in
                     print("on Saving")
                 }

                 .frame(minWidth: 300, minHeight: 250)

                 Button("Hola"){
                     print(9)
                     info.toggle()
                 }

             }

             .presentationDetents([.fraction(0.2), .medium, .large])
             .presentationContentInteraction(.scrolls)

         } */
    }
}

/*
 struct GeoPreview: PreviewProvider {
     static var previews: some View {
         XX()
     }

     struct XX: View {
         //@State var mode = false
         @State var showSettings = true
         //@State var path = GMSMutablePath()
         @StateObject var aqua = AquaFeelModel()
         @State var lead = LeadManager()//LeadViewModel(first_name: "Juan", last_name: "")
         @State var info = false
         //@State var selected:LeadModel? = LeadModel()
         //@State private var mapState = MapViewState(leads: [], path: GMSMutablePath(), mode: false, leadSelected: nil)

         var body: some View {
             MapViewControllerBridge(leads: $lead.leads, path: $aqua.path, mode: $aqua.mode, leadSelected: $lead.selected )
                 .edgesIgnoringSafeArea(.all)
             //.environmentObject($lead.leads)
                 .sheet(isPresented: $aqua.mode) {
                     PathOptionView(leads: $lead.leads, path: $aqua.path )
                         .presentationDetents([.fraction(0.30), .medium, .large])
                         .presentationContentInteraction(.scrolls)

                 }
                 .sheet(isPresented: $info){
                     //LeadDetailView(lead: lead.selected ?? LeadModel())

                     NavigationStack{
                         CreateLead(lead: Binding<LeadModel>(

                             get: { lead.selected ?? LeadModel() },
                             set: { lead.selected = $0 }
                         ), manager: lead){
                             print("never saving")
                         }
                         .presentationDetents([.medium, .large])
                         .presentationContentInteraction(.scrolls)
                         /* .toolbar{
                             ToolbarItem(placement: .navigationBarLeading) {
                                 Button("Cancelar") {
                                     // Acción al hacer clic en "Cancelar"
                                     info = false // Cierra el sheet
                                 }
                             }
                             ToolbarItem(placement: .navigationBarTrailing) {
                                 Button("Guardar") {
                                     // Acción al hacer clic en "Guardar"
                                     // Puedes realizar las acciones necesarias aquí
                                 }
                             }
                         } */
                     }

                 }
                 .onAppear{
                     //lead.loadAll()
                     lead.list()
                     print("onAppear")
                 }
                 .onReceive(lead.$selected) {x in

                     if let lead = x {
                         info = true
                     }

                 }

         }
     }
 }

 */
#Preview {
    MainAppScreenHomeScreenPreview()
    // HomeScreen(option:"b")
}
