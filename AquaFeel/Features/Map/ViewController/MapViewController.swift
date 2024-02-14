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
import UIKit
import SwiftUI
import GoogleMapsUtils
import UIKit.UIGestureRecognizerSubclass

var clusterManager: GMUClusterManager!
var c:MapViewCoordinator!

var start: Bool = false

class AquaFeelModel: ObservableObject {
    @Published var path = GMSMutablePath()
    @Published var mode = false
    
    
    
}

protocol MapDraw {
    func play()
    func stop()
    func pause()
    func get()
    func reset()
}

class Draw: MapDraw{
    
    let path = GMSMutablePath()
    var path2 = GMSMutablePath()
    var polygon = GMSPolyline()
    let mapView: GMSMapView
    let poly = GMSPolygon()
    let line = GMSPolyline()
    
    var start =  false
    /*
    var line: GMSPolyline {
        let polyline = GMSPolyline()
        polyline.path = path
        // Configura el estilo del polígono (opcional)
        polyline.strokeColor = color
        polyline.strokeWidth = CGFloat(strokeWidth)
        polyline.geodesic = true
        return polyline
    }
    
    */
    let strokeWidth = 2.0
    var color: UIColor = UIColor.orange
    
    
    init(map: GMSMapView) {
        
        print("INIT MapDraw")
        self.mapView = map
        
        poly.path = path
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.2)
        poly.isTappable = true
        
        line.path = path
        line.strokeColor = color
        line.strokeWidth = strokeWidth
        
    }
    
    func doLine(_ path: GMSMutablePath){
        
        line.path = path
        // Configura el estilo del polígono (opcional)
        line.strokeColor = color
        line.strokeWidth = strokeWidth
        
        line.geodesic = true
        
        line.map = mapView
        
    }
    
    func bye(){
        /*
        if !start {
            
            return
        }
        start = false
        */
        //path.removeAllCoordinates()
        
        path.add(path.coordinate(at: 0))
        //line.map = nil
        //doGeofence()
        
        //doLine2(path)
        
        doGeofence()
        path2 = GMSMutablePath(path: path)
        
        
        path.removeAllCoordinates()
        
        
    }
    
    func doGeofence(){
        
        poly.path = path
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.2)
        poly.map = mapView
        
        
    }
    
    func doLine2(_ path: GMSMutablePath){
        
        line.path = path
        // Configura el estilo del polígono (opcional)
        line.strokeColor = color
        line.strokeWidth = strokeWidth
        
        line.geodesic = true
        
        
        
        let image = UIImage(systemName: "circle.fill")!.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        
        image.withTintColor(.red)
        //image.withTintColor(.cyan)
        let stampStyle = GMSSpriteStyle(image: image)
        
        let transparentStampStroke = GMSStrokeStyle.transparentStroke(withStamp: stampStyle)
        
        
        let span = GMSStyleSpan(style: transparentStampStroke)
        /*
         let redWithStamp = GMSStrokeStyle.solidColor(.red)
         let image = UIImage(systemName: "circle.fill")! // Image could be from anywhere
         redWithStamp.stampStyle = GMSTextureStyle(image: image)
         let span = GMSStyleSpan(style: redWithStamp)
         
         */
        line.spans = [span]
        
        line.map = mapView
    }
    
    func doPoly(_ path: GMSMutablePath){
        
        poly.path = path
        // Configura el estilo del polígono (opcional)
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.01)
        //polygon.fillColor = UIColor.blue.withAlphaComponent(0.5)
        poly.geodesic = false
        
        poly.map = mapView
    }
    func add(coordinate: CLLocationCoordinate2D){
        
        //start = true
        self.path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        doLine(path)
    }
    
    func add2(coordinate: CLLocationCoordinate2D){
        self.path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)) //
        //let polygon = GMSPolygon(path: path)
        
        let solidRed = GMSStrokeStyle.solidColor(.red)
        let solidBlue = GMSStrokeStyle.solidColor(.blue)
        let solidBlueSpan = GMSStyleSpan(style: solidBlue)
        let redYellow = GMSStrokeStyle.gradient(from: .red, to: .yellow)
        let redYellowSpan = GMSStyleSpan(style: redYellow)
        
        
        polygon.path = path
        // Configura el estilo del polígono (opcional)
        //polygon.strokeColor = .yellow
        polygon.strokeWidth = 10
        //polygon.fillColor = UIColor.blue.withAlphaComponent(0.5)
        polygon.geodesic = true
        
        //let polyline = GMSPolyline(path: path)
        
        //let image = UIImage(systemName: "circle.fill")!.withTintColor(.orange, renderingMode: .alwaysTemplate)
        let largeFont = UIFont.systemFont(ofSize: 60)
        let configuration = UIImage.SymbolConfiguration(font: largeFont)
        
        let image = UIImage(systemName: "circle.fill")!.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        
        image.withTintColor(.red)
        //image.withTintColor(.cyan)
        let stampStyle = GMSSpriteStyle(image: image)
        
        let transparentStampStroke = GMSStrokeStyle.transparentStroke(withStamp: stampStyle)
        
        
        let span = GMSStyleSpan(style: transparentStampStroke)
        /*
         let redWithStamp = GMSStrokeStyle.solidColor(.red)
         let image = UIImage(systemName: "circle.fill")! // Image could be from anywhere
         redWithStamp.stampStyle = GMSTextureStyle(image: image)
         let span = GMSStyleSpan(style: redWithStamp)
         
         */
        polygon.spans = [span]
        /*
         polygon.spans = [
         GMSStyleSpan(style: solidRed, segments: 2.5),
         GMSStyleSpan(color: .gray),
         GMSStyleSpan(color: .purple, segments: 0.75),
         GMSStyleSpan(style: redYellow)
         ]
         
         let styles = [
         GMSStrokeStyle.solidColor(.systemYellow),
         GMSStrokeStyle.solidColor(.systemPink)
         ]
         let lengths: [NSNumber] = [100000, 100000]
         polygon.spans = GMSStyleSpans(
         polygon.path!,
         styles,
         lengths,
         GMSLengthKind.rhumb
         )
         */
        //polygon.strokeColor = .yellow
        
        if (mapView.mapCapabilities.contains(.spritePolylines)) {
            print(".......... SIIII")
            
        }
        
        
        //polygon.spans = [GMSStyleSpan(style: solidRed)]
        /*polygon.spans = [
         GMSStyleSpan(style: solidRed),
         GMSStyleSpan(style: solidRed),
         GMSStyleSpan(style: redYellow)
         ]
         */
        
        //polygon.zIndex = 1
        // Añade el polígono al mapa
        polygon.map = mapView
    }
    
    func play() {
        polygon = GMSPolyline()
    }
    
    func stop() {
        
    }
    
    func pause() {
        
    }
    
    func get() {
        
    }
    
    func reset() {
        
    }
    
    
    
}



protocol ResettableView {
    func resetPieces(_:DragDropGestureRecognizer)
}


class MapViewController:  UIViewController ,GMSMapViewDelegate, UIGestureRecognizerDelegate, ResettableView {
    
    let map =  GMSMapView()
    
    //var mode:Bool = false
    var mode: Binding<Bool>?
    //var path: GMSMutablePath?
    
    var path: Binding<GMSMutablePath>?
    var draw:Draw?
    var newPath = GMSMutablePath()
    
   
    var onPlay = false
    
    
    override func loadView() {
        super.loadView()
        map.camera = GMSCameraPosition(latitude: 37.36, longitude: -122.0, zoom: 5.0)
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        
        draw = Draw(map: map)
        
        //self.myDraw()
        
        //draw = Draw11(target: self,map: map)
        //draw?.play()
        //map.addGestureRecognizer(draw.drawGesture)
        //self.play()
        //draw.play2(drawGesture: UIPanGestureRecognizer(target: self, action: #selector(START)))
        //x = MapViewDelegateHandler(self)
        //map.delegate = draw  //x//self
        //map.isUserInteractionEnabled = false
        //map.settings.allowScrollGesturesDuringRotateOrZoom = false
        
        /*
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
         //map.addTarget(self, action: #selector(toggleGestures2), for: .touchUpInside)
         
         
         map.addGestureRecognizer(tapGestureRecognizer)
         
         
         let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draw._startDraw))
         map.addGestureRecognizer(panGestureRecognizer)
         
         
         let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
         map.addGestureRecognizer(gestureRecognizer)
         */
        //play()
        //map.delegate = self
        self.view = map
        /*
       
        map.settings.setAllGesturesEnabled(true)
        
        
        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(resetPieces(_:)))
        view.addGestureRecognizer(resetGestureRecognizer)
        
        //resetGestureRecognizer.delegate = self
        
        resetGestureRecognizer.cancelsTouchesInView = false
        
        */
    }
    
    func setPlay(){
        onPlay.toggle()
        if onPlay {
            play()
        }else{
            stop()
        }
        
    }
    
    func play(){
        print("play()")
        self.map.settings.setAllGesturesEnabled(false)
        
        
        let resetGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(self.resetPieces(_:)))
        self.view.addGestureRecognizer(resetGestureRecognizer)
        
        //resetGestureRecognizer.delegate = self
        
        resetGestureRecognizer.cancelsTouchesInView = false
    }
    
    func stop(){
        self.map.settings.setAllGesturesEnabled(true)
    }
    
    
    func showLeadsOptions(){
        print("\n\n========.....===================")
        
       
        
        if let path2 = draw?.path2 {
            path?.wrappedValue = GMSMutablePath(path: path2)
        }
        
        
        if let path = path?.wrappedValue {
            print("x-> path?.count(): ", path.count())
            
            for index in 0..<path.count() {
                let coordinate = path.coordinate(at: index)
                //print("x-> \(index) Latitud: \(coordinate.latitude), Longitud: \(coordinate.longitude)")
            }
        }
        
        
        print("New path count in ended ", newPath.count())
        
        for index in 0..<newPath.count() {
            let coordinate = newPath.coordinate(at: index)
            //print("Latitud: \(coordinate.latitude), Longitud: \(coordinate.longitude)")
        }
        //path?.wrappedValue = newPath
        print("================================\n\n")
        if let mode = mode {
            mode.wrappedValue = true
        }
    }
    func play1(){
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
        
        let location = gesture.location(in: self.view)
        if let tappedView = self.view.hitTest(location, with: nil) {
            
            print("no Se tocó la mapa: \(tappedView.self)")
            
            
            if tappedView.self is UIButton{
                print("Se tocóUN Boton \(tappedView.self)")
                return
            }
           
            print("layer ", tappedView.layer, self.view)
            if tappedView == self.view {
                print("Se tocó la vista del ViewController: MISMO")
                // Realiza acciones específicas para tu ViewController
                return
            }
            
        }
        
        
        
        
        
        
        switch gesture.state {
        case .began:
            // Inicia el dibujo
            
            
            
            
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            //print(coordinate.latitude)
            draw?.add(coordinate: coordinate)
            //print("Began drawing")
        case .changed:
            // Procesa los puntos tocados para dibujar
            //let touchedPoints = gesture.touchedPoints
            // Implementa tu lógica de dibujo aquí
            //print("Changed drawing: \(touchedPoints)")
            let tapPoint = gesture.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            //print(coordinate.latitude)
            draw?.add(coordinate: coordinate)
            //print("Changed drawing: (touchedPoints)")
        case .ended:
            // Finaliza el dibujo
            
            /*
            newPath = GMSMutablePath(path: draw?.path2 ?? GMSMutablePath())
            print(newPath.count())
            print("New path count in ended state:", newPath.count())

            path?.wrappedValue = newPath
            */
            draw?.bye()
            //newPath = GMSMutablePath(path: self.draw?.path2 ?? GMSMutablePath())
            
            //newPath = GMSMutablePath()
            //newPath.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
            //newPath.add(CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
            //newPath.add(CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
            
           
            print("New path count in ended state:", self.newPath.count())
            if let path2 = draw?.path2 {
                print("yes \(path2.count())")
                path?.wrappedValue = GMSMutablePath(path: path2)
                newPath = GMSMutablePath(path: path2)
            }
            
            
           
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
            
            /*
            if let path = path {
                print("Count: ")
                print(draw?.path2.count())
                path.wrappedValue = GMSMutablePath(path: draw?.path2 ?? GMSMutablePath()) //draw?.path2 ?? GMSMutablePath()
            }
             */
            //print("Ended drawing")
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
        print("queeee")
        
        return true
    }
    
    
    @objc func startDraw(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("handlePanGesture")
        if gestureRecognizer.state == .ended {
            print("Bye.................")
            //draw?.bye()
        }        // Actualiza la ruta que el usuario está dibujando.
        if gestureRecognizer.state == .began {
            print("hello")
            let tapPoint = gestureRecognizer.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            draw?.add(coordinate: coordinate)
            
        } else if gestureRecognizer.state == .changed {
            let tapPoint = gestureRecognizer.location(in: map)
            let coordinate = map.projection.coordinate(for: tapPoint)
            
            // Acciones a realizar cuando se toca el mapa
            //print("Tocaste en la coordenada: \(coordinate.latitude), \(coordinate.longitude)")
            
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
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer? = nil) -> Bool{
        print("handleTap")
        
        // Obtenga la ubicación del toque
        //let location = gestureRecognizer.location(in: mapView)
        // Coordine la ubicación del toque
        //let coordinate = mapView.projection.coordinate(for: location)
        // Implemente la acción deseada
        //print("Tocado en la coordenada: \(coordinate)")
        
        // En el método gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:) del UIGestureRecognizer, devuelve true para permitir que el usuario dibuje sobre el mapa mientras interactúa con otros elementos de la interfaz de usuario.
        return false
    }
    
    
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        let size: CGFloat = 40.0
        let items = [
            MapMenuItem(title: "a", image: "line.horizontal.3.decrease.circle", color: .darkGray){
                //self.stop()
                self.showLeadsOptions()
            },
            MapMenuItem(title: "b", image: "magnifyingglass", color: .darkGray),
            MapMenuItem(title: "c", image: "app.connected.to.app.below.fill", color: .darkGray),
            MapMenuItem(title: "d", image: "pin.fill", color: .darkGray){
                
                //self.stop()
            },
            MapMenuItem(title: "d", image: "hand.draw.fill", color: .darkGray){
                
                self.setPlay()
            }
        ]
        let stackView = UIStackView()
        //stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // Configuración del stack view
        stackView.axis = .vertical
        stackView.alignment = .leading
        //stackView.distribution = .fill
        //stackView.backgroundColor = .magenta
        stackView.spacing = 20  // Puedes ajustar el espaciado según tus necesidades
        stackView.isLayoutMarginsRelativeArrangement = true
        //stackView.isLayoutMarginsRelativeArrangement = true
        //stackView.translatesAutoresizingMaskIntoConstraints = true
        stackView.clipsToBounds = true
        items.forEach{ item in
            let button = UIButton(type: .system)
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
            let trashImage = UIImage(systemName: item.image, withConfiguration: symbolConfiguration)
            button.setImage(trashImage, for: .normal)
            
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
                button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
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
            
        }
        
        view.addSubview(stackView)
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            //stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 150),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            //stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        
        
        
        
    }
    
    @objc func toggleGestures() {
        map.miTest()
        print("x")
        //start = true
        map.settings.setAllGesturesEnabled(false)
        //map.settings.scrollGestures = false
        //button.setTitle(true ? "Disable Gestures" : "Enable Gestures", for: .normal)
    }
    
    @objc func toggleGestures2() {
        print("y")
        //start = false
        map.settings.setAllGesturesEnabled(true)
        //map.settings.scrollGestures = true
        //button.setTitle(true ? "Disable Gestures" : "Enable Gestures", for: .normal)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("handlePanGesture")
        if gestureRecognizer.state == .ended {
            
        }        // Actualiza la ruta que el usuario está dibujando.
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
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)  {
        print("willMove")
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print(".")
        let latitude = position.target.latitude
        let longitude = position.target.longitude
        
        //print("Posición del usuario cambiada a (Latitud: \(latitude), Longitud: \(longitude))")
        
        
        
        // Puedes realizar acciones adicionales basadas en el movimiento del usuario aquí
    }
    
    
    
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
     
     }
     */
    
    
    
    
}

struct MapViewControllerBridge: UIViewControllerRepresentable {
    //@State private var clusterManager: GMUClusterManager!
    
    //@EnvironmentObject var lead:LeadViewModel
    @Binding var leads: [LeadModel]
    
    @Binding var path:GMSMutablePath
    @Binding var mode: Bool
    //let path = GMSMutablePath()
    
    func makeUIViewController(context: Context) -> MapViewController {
        print("UNO......")
        //let viewController = MapViewController()
        //let mapView = GMSMapView()
        //mapView.delegate = context.coordinator
        //viewController.view = mapView
        
        //return viewController
        let uiViewController = MapViewController()
        uiViewController.mode = $mode
        uiViewController.path = $path
        //uiViewController.map.delegate = uiViewController
        //context.coordinator.mode = $mode
        //context.coordinator.path = $path
        //print(context.coordinator.test)
        //uiViewController.map.delegate = context.coordinator
        //c = context.coordinator
        //mapVV = uiViewController.map
        //mode = true
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        
        let mapView = uiViewController.map
        
        
        
        print("DOS......count: ", leads.count)
        let positionLondon = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0)
        let london = GMSMarker(position: positionLondon)
        
        
        
        let markerImage = UIImage(systemName: "house.fill")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.tintColor = UIColor.red
        london.title = "London"
        
        
        let circleIconView = StatusUIView(status: .nho)
        circleIconView.frame = CGRect(x: 120, y: 120, width: 50, height: 50)
        
        //let circleIconView = CircleIconView(systemName: "dot.radiowaves.up.forward")
        //circleIconView.frame = CGRect(x: 120, y: 120, width: 126, height: 126)
        //MapIconView
        
        london.iconView = circleIconView
        london.map = uiViewController.map
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Register self to listen to GMSMapViewDelegate events.
        //clusterManager.setMapDelegate(c)//(context.coordinator)//(c)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
    }
    
    private func generateClusterItems() {
        print("generateClusterItems: \(leads.count)")
        for leadModel in leads {
            //print( leadModel.first_name ?? "-/n")
            if let latitude = Double(leadModel.latitude),
               let longitude = Double(leadModel.longitude) {
                
                
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                marker.title = leadModel.first_name 
                
                let circleIconView = getUIImage(name: leadModel.status_id.name ?? "")
                circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)
                
                //let circleIconView = CircleIconView(systemName: "dot.radiowaves.up.forward")
                //circleIconView.frame = CGRect(x: 120, y: 120, width: 126, height: 126)
                //MapIconView
                
                marker.iconView = circleIconView
                
                //marker.map = mapView
                clusterManager.add(marker)
            }
        }
        /*
         let extent = 0.2
         for _ in 1...kClusterItemCount {
         let lat = kCameraLatitude + extent * randomScale()
         let lng = kCameraLongitude + extent * randomScale()
         let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
         let marker = GMSMarker(position: position)
         //clusterManager.add(marker)
         }
         */
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
     
     func makeCoordinator() -> MapViewCoordinator {
         print("TRES ...")
         return MapViewCoordinator(self, path: path)
     }
     
    private func animateToSelectedMarker(viewController: MapViewController) {
                
        //let map = viewController.map
        
    }
    
    
    
    
}

final class MapViewCoordinator: NSObject, GMSMapViewDelegate/*, GMUClusterManagerDelegate*/ {
    var mapViewControllerBridge: MapViewControllerBridge
    //var path = GMSMutablePath()
    var polygon = GMSPolygon()
    let test = "ESPN"
    
    var mode: Binding<Bool>?
    
    init(_ mapViewControllerBridge: MapViewControllerBridge, path: GMSMutablePath) {
        print("CUATRO......")
        self.mapViewControllerBridge = mapViewControllerBridge
        
    }
    /*
     func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
     print("un paso para la humanidad")
     return false
     }
     */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            
            print("......Did tap cluster")
            return true
        }
        
        print(".....Did tap marker")
        return false
    }
    
    /*
     func makeClusterManager(for mapView: GMSMapView) -> GMUClusterManager {
     print("CINCO......")
     // Configurar GMUClusterManager
     let iconGenerator = GMUDefaultClusterIconGenerator()
     let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
     let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
     let manager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
     manager.setDelegate(self, mapDelegate: self)
     return manager
     }
     */
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("MapViewCoordinator SIX")
        print(gesture)
        //mapView.settings.setAllGesturesEnabled(false)
        //self.mapViewControllerBridge.mapViewWillMove(gesture)
        /*
         let target = CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0)
         let cameraUpdate = GMSCameraUpdate.setTarget(target)
         mapView.moveCamera(cameraUpdate)
         */
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        print("MapViewCoordinator TEN")
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        // Se llama cuando se toca la ventana de información de un marcador específico
        print("MapViewCoordinator SEVEN")
        print(marker.title ?? "")
        //mapView.settings.setAllGesturesEnabled(false)
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("MapViewCoordinator NINE")
        if let mode = mode {
            mode.wrappedValue = true
        }
        
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = position.target.latitude
        let longitude = position.target.longitude
        
        print("Posición del usuario cambiada a (Latitud: \(latitude), Longitud: \(longitude))")
                
        
        // Puedes realizar acciones adicionales basadas en el movimiento del usuario aquí
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("MapViewCoordinator EIGHT.")
        
        if !start {
            polygon.path = GMSMutablePath()
            print("nothing")
            return
        }
        /*
        
        self.path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)) //
        //let polygon = GMSPolygon(path: path)
        polygon.path = path
        // Configura el estilo del polígono (opcional)
        polygon.strokeColor = .blue
        polygon.strokeWidth = 2.0
        polygon.fillColor = UIColor.blue.withAlphaComponent(0.5)
        
        // Añade el polígono al mapa
        polygon.map = mapView
        */
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("OJHHHHH")
    }
    
}

struct LeadMap:View {
    //@State var mode = false
    @State var showSettings = true
    //@State var path = GMSMutablePath()
    @StateObject var aqua = AquaFeelModel()
    @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    var body: some View {
        MapViewControllerBridge(leads: $lead.leads, path: $aqua.path, mode: $aqua.mode )
            .edgesIgnoringSafeArea(.all)
        //.environmentObject($lead.leads)
            .sheet(isPresented: $aqua.mode) {
                PathOptionView(path: $aqua.path )
                    .presentationDetents([.fraction(0.30), .medium, .large])
                    .presentationContentInteraction(.scrolls)
            }.onAppear{
                lead.loadAll()
                print("onAppear")
            }
    }
}

struct GeoPreview: PreviewProvider {
    static var previews: some View {
        XX()
    }
    
    struct XX: View {
        //@State var mode = false
        @State var showSettings = true
        //@State var path = GMSMutablePath()
        @StateObject var aqua = AquaFeelModel()
        @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
        var body: some View {
            MapViewControllerBridge(leads: $lead.leads, path: $aqua.path, mode: $aqua.mode )
                .edgesIgnoringSafeArea(.all)
                //.environmentObject($lead.leads)
                .sheet(isPresented: $aqua.mode) {
                    PathOptionView(path: $aqua.path )
                        .presentationDetents([.fraction(0.30), .medium, .large])
                        .presentationContentInteraction(.scrolls)
                }.onAppear{
                    lead.loadAll()
                    print("onAppear")
                }
        }
    }
}
