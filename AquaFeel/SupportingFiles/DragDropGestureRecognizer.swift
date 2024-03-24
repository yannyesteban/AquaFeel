//
//  DragDropGestureRecognizer.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/2/24.
//
import GoogleMaps
import UIKit
import SwiftUI
import GoogleMapsUtils
import UIKit.UIGestureRecognizerSubclass

class DragDropGestureRecognizer: UIGestureRecognizer {
    
    private var trackedTouch: UITouch?
    private var touchedPoints = [CGPoint]()
    
    /**
     ResetGestureRecognizer is a one-touch recognizer, so begins only if touches.count equals to 1.
     
     After this gesture recognizer begins, users can add more touches which trigger this method.
     This gesture recognizer ignores the touches if they are not the tracked one.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        //print(" ==== touchesBegan ....")
        if touches.count != 1 { // Ignore the touches if there are more than one.
            for touch in touches {
                ignore(touch, for: event)
            }
            state = .failed
            return
        }
        /**
         Pick up the first touch if the gesture recognizer isn't tracking any touch yet,
         and ignore the touches if they are not the tracked one without turning state to .failed.
         */
        trackedTouch = trackedTouch ?? touches.first
        if let touch = touches.first, touch != trackedTouch! {
            ignore(touch, for: event)
            return
        }
        state = .began
    }
    
    /**
     Gathering the touched points. Ignore the pending touches if the state has already failed.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        //print(" ==== move move ....")
        guard state != .failed else { // Ignore pending touches if the state is already .failed.
            return
        }
        guard let touch = touches.first, let window = view?.window else {
            fatalError("Failed to unwrap `touches.first` and `view?.window`!")
        }
        touchedPoints.append(touch.location(in: window))
        state = .changed
    }
    
    /**
     Check if the touched points fit the custom gesture, and change the state accordingly.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        //print(" ==== touchesEnded ....")
        let count = 5 + countHorizontalTurning(touchedPoints: touchedPoints)
        state = count > 2 ? .ended : .failed
        print("\(state == .ended ? "Recognized" : "Failed"): horizontal turning count = \(count)")
    }
    
    /**
     Clear the touched points and set the state to .possible.
     */
    override func reset() {
        //print(" ==== reset ....")
        super.reset()
        trackedTouch = nil
        touchedPoints.removeAll()
        state = .possible
    }
    
    /**
     Cancel the gesture recognizing.
     */
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        print(" ==== touchesCancelled ....")
        state = .cancelled
    }
    
    /**
     Count the horizontal turnings for the touched points and return the number.
     
     This sample determines a horizontal turning by calculating the horizontal distances between every two points and checking their signs.
     If a finger goes right and then turns left (or vice versa), the path will have a turning point. The horizontal distance from the point to its
     previous neighbor must be larger than 0, and from the next neighbor to the point must be smaller than 0.
     
     This sample filters out the points that have a same x value because they can't be a horizontal turning, but doesn't go further to eliminate
     the other noises or check the segment distances in the path. Real apps might consider doing that to improve the gesture recognition
     accuracy and avoid recognizing false positive gestures.
     */
    private func countHorizontalTurning(touchedPoints: [CGPoint]) -> Int {
        var distances = [CGFloat]()
        var turningCount = 0
        /**
         Calculate the horizontal distances between every two points.
         Ignore the points that have a same x value because they can't be a horizontal turning.
         */
        guard !touchedPoints.isEmpty else { return 0 }
        _ = touchedPoints.reduce(touchedPoints[0]) { point1, point2 in
            if point2.x != point1.x {
                distances.append(point2.x - point1.x)
            }
            return point2
        }
        /**
         Determine the horizontal turning points by checking the sign of the neighbor distance values.
         */
        guard !distances.isEmpty else { return 0 }
        _ = distances.reduce(distances[0]) { distance1, distance2 in
            if (distance1 > 0 && distance2 < 0) || (distance1 < 0 && distance2 > 0) {
                turningCount += 1
            }
            return distance2
        }
        return turningCount
    }
}



class CustomGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        // Lógica para manejar el inicio del gesto
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        // Lógica para manejar el movimiento del gesto
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        // Lógica para manejar el final del gesto
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        // Lógica para manejar la cancelación del gesto
        state = .cancelled
    }
}

struct MapButtonView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

protocol Drawv20{
    var map: GMSMapView  { get }
    func myDraw()
    
    //func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
}

extension Drawv20{
    func myDraw(){
        //map.settings.setAllGesturesEnabled(false)
        print("que cosas 1")
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("arenita playita 2.0")
        
        
    }
    func _startDraw(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("_startDraw")
        if gestureRecognizer.state == .ended {
            
        }        // Actualiza la ruta que el usuario está dibujando.
        if gestureRecognizer.state == .began {
            
            
        } else if gestureRecognizer.state == .changed {
            //let tapPoint = gestureRecognizer.location(in: map)
            //let coordinate = map.projection.coordinate(for: tapPoint)
            
            // Acciones a realizar cuando se toca el mapa
            //print("Tocaste en la coordenada: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }
}

class DrawV10: NSObject, GMSMapViewDelegate{
    var map = GMSMapView()
    //let map: GMSMapView
    //let path = GMSMutablePath()
    //let polygon = GMSPolygon()
    let target: UIViewController
    var drawGesture: UIPanGestureRecognizer
    
    init(target: UIViewController, map: GMSMapView) {
        self.map = map
        self.target = target
        self.drawGesture = UIPanGestureRecognizer(target: target, action: #selector(self._startDraw))
        
        print("play")
        map.settings.setAllGesturesEnabled(false)
        //map.addGestureRecognizer(drawGesture)
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("arenita playita 1")
        
        
        
    }
    
    func play(){
        print("play")
        map.settings.setAllGesturesEnabled(false)
        self.drawGesture = UIPanGestureRecognizer(target: target, action: #selector(self._startDraw))
        //UIPanGestureRecognizer(target: self, action: #selector(_startDraw))
        map.addGestureRecognizer(drawGesture)
    }
    
    func play2(drawGesture: UIPanGestureRecognizer){
        print("play 2")
        map.settings.setAllGesturesEnabled(false)
        map.addGestureRecognizer(drawGesture)
    }
    
    func stop(){
        print("stop")
        //map.removeGestureRecognizer(drawGesture)
        map.settings.setAllGesturesEnabled(true)
    }
    
    @objc func _startDraw(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("_startDraw")
        if gestureRecognizer.state == .ended {
            
        }        // Actualiza la ruta que el usuario está dibujando.
        if gestureRecognizer.state == .began {
            
            
        } else if gestureRecognizer.state == .changed {
            //let tapPoint = gestureRecognizer.location(in: map)
            //let coordinate = map.projection.coordinate(for: tapPoint)
            
            // Acciones a realizar cuando se toca el mapa
            //print("Tocaste en la coordenada: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }
}
class MapViewDelegateHandler2: NSObject, GMSMapViewDelegate {
    
    weak var mapViewController: MapViewController?
    
    init(_ mapViewController: MapViewController) {
        print("Tocaste el marcador 10.0")
        self.mapViewController = mapViewController
    }
    
    // Implementa los métodos del protocolo GMSMapViewDelegate según tus necesidades
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Tocaste el marcador")
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Tocaste la ventana de información del marcador")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("Mantuviste presionada la ventana de información del marcador")
    }
}

extension GMSMapView {
    
    func miTest() {
        // Implementa aquí la lógica de tu nuevo método
        print("¡Este es mi nuevo método en GMSMapView!")
    }
    
    // Puedes agregar más métodos según sea necesario
}
