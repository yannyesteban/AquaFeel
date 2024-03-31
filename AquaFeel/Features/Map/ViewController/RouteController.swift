//
//  RouteControler.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/3/24.
//

import SwiftUI

enum MapState {
    case none
    case zoom
    case bound
    case next
    case prev
    case tap
    
    case lasso
    case draw
}

struct RouteRequest {
    let origin: String
    let destination: String
    let waypoints: [String]
    let mode: String = "driving"
    let optimize = true
}

class MapManager: ObservableObject {
    @Published var lead: LeadModel?
    @Published var lastLead = 0
    @Published var lastMarker: GMSMarker?
    @Published var state: MapState = .none
    @Published var zoom: Int = 0
    @Published var bounds: GMSCoordinateBounds?
    @Published var route: RouteResponse?
    @Published var lastRoute = 0
    var pos = 0

    func setBound() {
        state = .bound
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
        print("prev")

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

    func find(_ index: Int) {
        if let myRoute = route?.routes[lastRoute] {
            // lastLead = (lastLead % myRoute.leads.count) + 1
            // print("lastLead", lastLead)
            if let leadFound = myRoute.leads.first(where: { $0.routeOrder == index }) {
                lastLead = index
                lead = leadFound
                state = .tap
            }
        }
    }
}

class DirectionManager: ObservableObject {
    @Published var route: RouteResponse?
    @Published var origin = ""
    @Published var destination = ""
    var waypoints: [String] = []
    let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"

    func search(request: RouteRequest, leads: [LeadModel]) async throws -> RouteResponse? {
        var params: [String: String] = [:]

        params["origin"] = request.origin
        params["destination"] = request.destination

        var ways = request.waypoints.joined(separator: "|")

        if ways != "" {
            if request.optimize {
                ways = "optimize:true|" + ways
            }
            params["waypoints"] = ways
        }

        params["mode"] = "driving"
        params["key"] = apiKey

        let info = ApiConfig(method: "GET", host: "maps.googleapis.com", path: "/maps/api/directions/json", token: "", params: params)

        do {
            var response: RouteResponse = try await fetching(config: info)

            print("result.status:", response.status)

            // var response = response1
            for i in response.routes.indices {
                // i.leads = []
                for j in response.routes[i].waypointOrder {
                    var lead = leads[j]

                    lead.routeOrder = j + 1
                    response.routes[i].leads.append(lead)
                }

                print("i.waypointOrder", response.routes[i].waypointOrder)
            }
            // prettyPrint(response)
            /*
             let response1 = response
             DispatchQueue.main.async {
                 // let response1 = response
                 self.route = response1
             }
             */
            return response
        } catch {
            throw error
        }
    }
}

import GoogleMaps // Asegúrate de haber importado el framework de Google Maps en tu proyecto
import UIKit
struct MapMark {
    var coordinate: CLLocationCoordinate2D
    var icon: String
}

class RouterMapsX: UIViewController {
    let map = GMSMapView()
    var isAnimating: Bool = false

    var markerDictionary: [Int: GMSMarker] = [:]
    var lastMarker: Int?

    override func loadView() {
        super.loadView()
        view = map
    }

    /*
     func fitBounds(){
         guard let routes = route?.routes else {
             return
         }

         for route in routes {

             let bounds = route.bounds
             let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
             let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
             fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))

         }
     }
     */
    func fitBounds(bounds: GMSCoordinateBounds) {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
         map.animate(with: update)
        //map.moveCamera(update)
    }

    func addMarker(marker: GMSMarker) {
        marker.map = map
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
}

class RouterMaps: UIViewController {
    var routeManager: RouteManager
    var route: RouteResponse?
    let map = GMSMapView()

    var lastMarker: Binding<GMSMarker?>?

    init(routeManager: RouteManager) {
        self.routeManager = routeManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        // withLatitude: 33.1510323, longitude: -97.09571889999999
        let longitude = -97.09571889999999 // -74.0060 // -122.008972 //-122.008972
        let latitude = 33.1510323 // 40.7128 // 39.2750209// 37.33464379999999

        // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
        // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        view = map

        map.delegate = self

        drawRoute()
    }

    func fitBounds() {
        guard let routes = route?.routes else {
            return
        }

        for route in routes {
            let bounds = route.bounds
            let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
            let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
            fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))
        }
    }

    func fitBounds(bounds: GMSCoordinateBounds) {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        // map.animate(with: update)
        map.moveCamera(update)
    }

    func drawMarker(leads: [LeadModel]) {
        for lead in leads {
            let latitude = Double(lead.latitude) ?? 0.0
            let longitude = Double(lead.longitude) ?? 0.0
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            let marker = GMSMarker(position: position)
            // marker.icon = UIImage(systemName: "trash.circle.fill")
            /*
             let markerImageView = UIImageView(image: UIImage(systemName: "trash.circle.fill"))
             markerImageView.tintColor = .red

             markerImageView.layer.shadowColor = UIColor.black.cgColor
             markerImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
             markerImageView.layer.shadowOpacity = 0.7
             markerImageView.layer.shadowRadius = 3

             let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
             label.textAlignment = .center
             label.textColor = .white
             label.backgroundColor = .blue
             label.layer.cornerRadius = 15
             label.clipsToBounds = true
             label.font = UIFont.boldSystemFont(ofSize: 16)
             label.text = "2" // Coloca el número deseado aquí
             marker.iconView = label
             //marker.iconView = markerImageView
             // Ajustar el tamaño del icono del marcador
             markerImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
             */

            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

            // Agregar el icono al customView
            let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            iconImageView.image = UIImage(systemName: "trash.circle.fill")
            iconImageView.tintColor = .red // Color del icono
            customView.addSubview(iconImageView)

            let label = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
            label.textAlignment = .center
            label.textColor = .white
            label.backgroundColor = .blue
            label.layer.cornerRadius = 5
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = lead.routeOrder.formatted() // Número del marcador

            marker.iconView = customView

            marker.map = map
        }
    }

    func drawRoute() {
        guard let routes = route?.routes else {
            return
        }

        for route in routes {
            let path = GMSPath(fromEncodedPath: route.overviewPolyline.points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = UIColor.orange
            polyline.strokeWidth = 5.0
            polyline.map = map
            let bounds = route.bounds
            let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
            let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
            fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))

            drawMarker(leads: route.leads)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let customGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(handleCustomGesture(_:)))

        view.addGestureRecognizer(customGestureRecognizer)
    }

    @objc func handleCustomGesture(_ gesture: CustomGestureRecognizer) {
        // Lógica para manejar el gesto personalizado
        switch gesture.state {
        case .began:
            print("began")

        case .changed:
            print("changed")
        case .ended:
            print("ended")
        default:
            print("default")
        }
    }
}

extension RouterMaps: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)

        return false
    }
}

struct RouterMapsView: UIViewControllerRepresentable {
    @ObservedObject var mapManager = MapManager()
    @ObservedObject var routeManager = RouteManager()
    // @StateObject var directionManager = DirectionManager()
    @State var zoom: Int = 10

    @State private var changedState: MapState = .none

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self, mapManager: mapManager)
    }

    func makeUIViewController(context: Context) -> RouterMapsX {
        let uiViewController = RouterMapsX()
        uiViewController.map.delegate = context.coordinator
        return uiViewController
    }

    func updateUIViewController(_ uiViewController: RouterMapsX, context: Context) {
        print("- - - - - ", mapManager.state)

        if mapManager.state == .next || mapManager.state == .prev || mapManager.state == .tap {
            DispatchQueue.main.async {
                if let lead = mapManager.lead {
                    uiViewController.goto(lead: lead)
                }
            }

            return
        }

        if mapManager.state == .bound {
            if let routes = mapManager.route?.routes {
                for route in routes {
                    let bounds = route.bounds
                    let northeast = CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)
                    let southwest = CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng)
                    uiViewController.fitBounds(bounds: GMSCoordinateBounds(coordinate: northeast, coordinate: southwest))
                }
            }

            return
        }

        if let route = mapManager.route {
            uiViewController.drawRoute(routes: route.routes)
        }
    }

    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        var mapViewControllerBridge: RouterMapsView
        @ObservedObject var mapManager = MapManager()
        init(_ mapViewControllerBridge: RouterMapsView, mapManager: MapManager) {
            self.mapViewControllerBridge = mapViewControllerBridge
            self.mapManager = mapManager
        }

        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            mapView.animate(toLocation: marker.position)

            if let index = marker.userData as? Int {
                mapManager.find(index)
            }

            return false
        }
    }
}

struct RouteMapsScreen: View {
    var profile: ProfileManager
    @State var routeId: String = "6605d1795cc75bdb59dcbfbe" // "660392ab5cc75bdb59dca01b"
    @StateObject var mapManager = MapManager()
    @StateObject var routeManager = RouteManager()
    @StateObject var directionManager = DirectionManager()
    @ObservedObject var leadManager = LeadManager()

    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false

    @State var yDragTranslation: CGFloat = 0

    @State var popupVisible = false
    @State var scrollViewHeight: CGFloat = -50
    @State var showInfo = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                RouterMapsView(mapManager: mapManager, routeManager: routeManager)

                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        VStack {
                            Button {
                                mapManager.lead?.makePhoneCall()

                            } label: {
                                Image(systemName: "phone")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .disabled(mapManager.lead?.phone.isEmpty ?? true || mapManager.lead == nil)
                            .padding(10)
                            Button {
                                mapManager.lead?.sendSMS()
                            } label: {
                                Image(systemName: "message")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .disabled(mapManager.lead?.phone.isEmpty ?? true || mapManager.lead == nil)
                            .padding(10)

                            Button {
                                mapManager.lead!.openGoogleMaps()
                            } label: {
                                Image(systemName: "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .disabled(mapManager.lead == nil)
                            .padding(10)
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        VStack {
                            Button {
                                mapManager.setBound()
                            } label: {
                                Image(systemName: "viewfinder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            /*
                             Button(action: {
                                 print("ok")
                                 popupVisible.toggle()

                             }) {
                                 Image(systemName: "camera.fill")
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(width: 20, height: 20)
                                     .foregroundColor(.white)
                                     .padding()
                                     .background(Color.accentColor)
                                     .clipShape(Circle())
                                     .shadow(radius: 10)
                             }.padding(10)
                              */
                            Button(action: {
                                loadApi()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }.padding(10)
                        }
                    }

                HStack {
                    VStack(alignment: .leading) {
                        Spacer()

                        HStack {
                            Button(action: {
                                mapManager.prevMark()
                            }) {
                                Image(systemName: "arrow.left.circle")

                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.blue)
                                    .padding()

                                    //.shadow(radius: 10)
                            }
                            

                            if mapManager.lead != nil {
                                HStack {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .center) {
                                            SuperIcon2(status: Binding(
                                                get: { getStatusType(from: mapManager.lead?.status_id.name ?? "") },
                                                set: { _ in
                                                }
                                            ))
                                            .frame(width: 34, height: 34)

                                            Text("# \(mapManager.lead?.routeOrder ?? 0)")

                                                .font(.headline)
                                                .foregroundColor(Color.accentColor)
                                        }
                                        .padding(3)

                                        VStack(alignment: .leading) {
                                            Text("\(mapManager.lead?.first_name ?? "") \(mapManager.lead?.last_name ?? "")")
                                                .font(.headline)
                                                .foregroundColor(Color.black)

                                            Text("\(mapManager.lead?.street_address ?? "")")
                                                .font(.subheadline)
                                        }

                                        Spacer()
                                    }
                                    .foregroundColor(Color.black.opacity(0.8))

                                    .background(Color.white.opacity(0.7))

                                    .cornerRadius(10)
                                    .padding(0)
                                }
                                .onTapGesture {
                                    showInfo.toggle()
                                }

                            } else {
                                Spacer()
                            }

                            Button(action: {
                                mapManager.nextMark()
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.blue)
                                    .padding()

                                   
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }

                CitiesList {
                    self.zoomInCenter = false
                    self.expandList = false
                } handleAction: {
                    self.expandList.toggle()
                }.background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(
                        x: 0,
                        y: geometry.size.height - (expandList ? scrollViewHeight + 150 : scrollViewHeight)
                    )
                    .offset(x: 0, y: self.yDragTranslation)
                    .animation(.spring(), value: self.yDragTranslation)
                    .gesture(
                        DragGesture().onChanged { value in
                            self.yDragTranslation = value.translation.height
                        }.onEnded { value in
                            self.expandList = (value.translation.height < -120)
                            self.yDragTranslation = 0
                        }
                    )
                    .shadow(radius: 10)
            }
        }
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                CreateLead(profile: profile, lead: Binding<LeadModel>(
                    get: { mapManager.lead ?? LeadModel() },
                    set: { mapManager.lead = $0 }
                ), mode: 2, manager: leadManager, updated: .constant(false)) { result in
                    if result {
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showInfo.toggle()
                        }) {
                            Image(systemName: "arrow.left")
                        }
                    }
                }
            }
        }

        .onChange(of: popupVisible) { value in
            withAnimation {
                if value {
                    self.scrollViewHeight = 100
                } else {
                    scrollViewHeight = -50
                }
            }
        }
        .onAppear{
            
           loadApi()
        }

        
    }
    
    func loadApi(){
        Task{
            if routeId != "" {
                
                
                try? await routeManager.detail(routeId: routeId)
                
                let request = RouteRequest(origin: routeManager.route.startingAddress, destination: routeManager.route.endingAddress, waypoints: routeManager.route.leads.map({
                    $0.latitude + "," + $0.longitude
                    // $0.street_address
                }))
                
                let response = try? await directionManager.search(request: request, leads: routeManager.route.leads)
                
                mapManager.route = response
                
                
            }
        }
        
    }
}

struct ContentView_Previews1010: PreviewProvider {
    static var previews: some View {
        RouteMapsScreen(profile: ProfileManager())
    }
}
