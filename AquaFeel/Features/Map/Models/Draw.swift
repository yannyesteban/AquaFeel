//
//  Draw.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/2/24.
//

import Foundation

import GoogleMaps
import GoogleMapsUtils

class Draw: MapDraw {
    let path = GMSMutablePath()
    var path2 = GMSMutablePath()
    var polygon = GMSPolyline()
    let mapView: GMSMapView
    let poly = GMSPolygon()
    let line = GMSPolyline()

    var start = false
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
        mapView = map

        poly.path = path
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.2)
        poly.isTappable = true

        line.path = path
        line.strokeColor = color
        line.strokeWidth = strokeWidth
    }

    func doLine(_ path: GMSMutablePath) {
        line.path = path
        // Configura el estilo del polígono (opcional)
        line.strokeColor = color
        line.strokeWidth = strokeWidth

        line.geodesic = true

        line.map = mapView
    }

    func bye() {
        /*
         if !start {

         return
         }
         start = false
         */
        // path.removeAllCoordinates()

        path.add(path.coordinate(at: 0))
        // line.map = nil
        // doGeofence()

        // doLine2(path)

        doGeofence()
        path2 = GMSMutablePath(path: path)

        path.removeAllCoordinates()
    }

    func doGeofence() {
        poly.path = path
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.2)
        poly.map = mapView
    }

    func doLine2(_ path: GMSMutablePath) {
        line.path = path
        // Configura el estilo del polígono (opcional)
        line.strokeColor = color
        line.strokeWidth = strokeWidth

        line.geodesic = true

        let image = UIImage(systemName: "circle.fill")!.withTintColor(.red, renderingMode: .alwaysOriginal)

        image.withTintColor(.red)
        // image.withTintColor(.cyan)
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

    func doPoly(_ path: GMSMutablePath) {
        poly.path = path
        // Configura el estilo del polígono (opcional)
        poly.strokeColor = color
        poly.strokeWidth = strokeWidth
        poly.fillColor = color.withAlphaComponent(0.01)
        // polygon.fillColor = UIColor.blue.withAlphaComponent(0.5)
        poly.geodesic = false

        poly.map = mapView
    }

    func add(coordinate: CLLocationCoordinate2D) {
        // start = true
        path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))

        doLine(path)
    }

    func add2(coordinate: CLLocationCoordinate2D) {
        path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)) //
        // let polygon = GMSPolygon(path: path)

        let solidRed = GMSStrokeStyle.solidColor(.red)
        let solidBlue = GMSStrokeStyle.solidColor(.blue)
        let solidBlueSpan = GMSStyleSpan(style: solidBlue)
        let redYellow = GMSStrokeStyle.gradient(from: .red, to: .yellow)
        let redYellowSpan = GMSStyleSpan(style: redYellow)

        polygon.path = path
        // Configura el estilo del polígono (opcional)
        // polygon.strokeColor = .yellow
        polygon.strokeWidth = 10
        // polygon.fillColor = UIColor.blue.withAlphaComponent(0.5)
        polygon.geodesic = true

        // let polyline = GMSPolyline(path: path)

        // let image = UIImage(systemName: "circle.fill")!.withTintColor(.orange, renderingMode: .alwaysTemplate)
        let largeFont = UIFont.systemFont(ofSize: 60)
        let configuration = UIImage.SymbolConfiguration(font: largeFont)

        let image = UIImage(systemName: "circle.fill")!.withTintColor(.red, renderingMode: .alwaysOriginal)

        image.withTintColor(.red)
        // image.withTintColor(.cyan)
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
        // polygon.strokeColor = .yellow

        if mapView.mapCapabilities.contains(.spritePolylines) {
            print(".......... SIIII")
        }

        // polygon.spans = [GMSStyleSpan(style: solidRed)]
        /* polygon.spans = [
         GMSStyleSpan(style: solidRed),
         GMSStyleSpan(style: solidRed),
         GMSStyleSpan(style: redYellow)
         ]
         */

        // polygon.zIndex = 1
        // Añade el polígono al mapa
        polygon.map = mapView
    }

    func play() {
        polygon = GMSPolyline()
    }

    func stop() {
        // path.removeAllCoordinates()
        line.map = nil
        poly.map = nil
    }

    func pause() {
    }

    func get() {
    }

    func reset() {
    }
}

class MapClusterIconGenerator: GMUDefaultClusterIconGenerator {
    override func icon(forSize size: UInt) -> UIImage {
        let image = textToImage(drawText: String(size) as NSString,
                                inImage: UIImage(named: "cluster")!,
                                font: UIFont.systemFont(ofSize: 12))
        return image
    }

    private func textToImage(drawText text: NSString, inImage image: UIImage, font: UIFont) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.center
        let textColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: textStyle,
            NSAttributedString.Key.foregroundColor: textColor]

        // vertically center (depending on font)
        let textH = font.lineHeight
        let textY = (image.size.height - textH) / 2
        let textRect = CGRect(x: 0, y: textY, width: image.size.width, height: textH)
        text.draw(in: textRect.integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

class DrawMark: NSObject, GMSMapViewDelegate {
    let mapView: GMSMapView
    var marker = GMSMarker()
    var position: CLLocationCoordinate2D?
    var state: Int = 0
    
    var onCreate: (CLLocationCoordinate2D?) -> Void
    
    init(map: GMSMapView, onCreate: @escaping (CLLocationCoordinate2D?) -> Void) {
        mapView = map
        position = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        //marker.isDraggable = false
        marker.title = "Lead"
        marker.snippet = "Generic"
        self.onCreate = onCreate
    }

    func play() {
    }

    func reset() {
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("arenita bebita 0.0")

        doMark(coordinate)
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        stop()
    }

    func doMark(_ coordinate: CLLocationCoordinate2D) {
        if marker.map == nil {
            marker.map = mapView
        }

        marker.position = coordinate
    }

    func stop() {
        print("delete mark")
        marker.map = nil
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let title = marker.title {
            if let snippet = marker.snippet {
                print("marker title: \(title): snippet: \(snippet)")
            }
        }
        position = marker.position
        onCreate(position)
        return true
    }

    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("didBeginDragging")
    }

    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }

    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
    }
}
