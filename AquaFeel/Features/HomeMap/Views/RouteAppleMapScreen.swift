//
//  RouteAppleMapScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/5/24.
//

import CoreLocation
import GoogleMaps
import MapKit
import SwiftUI

class HomeAppleMapsViewController: UIViewController, MKMapViewDelegate {
    let map = GMSMapView()
    var mapView = MKMapView()
    var location: CLLocationCoordinate2D?

    var markerDictionary: [Int: GMSMarker] = [:]
    var lastMarker: Int?

    var lastCluster = "default"
    var clusters: [String: MapsCluster] = [:]

    var markers: [GMSMarker] = []

    init(location: CLLocationCoordinate2D) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        mapView.delegate = self

        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configura la región inicial del mapa
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        // Agrega un marcador en la ubicación inicial
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation.coordinate
        annotation.title = "Ubicación inicial"
        mapView.addAnnotation(annotation)

        let coordinates = [CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), .init(latitude: 37.7949, longitude: -122.4994)]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        // Agregar la polilínea al mapa
        mapView.addOverlay(polyline)

        mapView.setRegion(coordinateRegion, animated: true)

        // create two dummy locations
        let loc1 = CLLocationCoordinate2D(latitude: 40.741895, longitude: -73.989308)
        let loc2 = CLLocationCoordinate2D(latitude: 40.728448, longitude: -73.717996)

        // find route
        showRouteOnMap(pickupCoordinate: loc1, destinationCoordinate: loc2)
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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        return renderer
    }
}

struct HomeAppleMapsRepresentable: UIViewControllerRepresentable {
    @Binding var location: CLLocationCoordinate2D

    var onInit: ((MKMapView) -> Void)?
    func makeUIViewController(context: Context) -> HomeAppleMapsViewController {
        let uiViewController = HomeAppleMapsViewController(location: location)

        onInit?(uiViewController.mapView)

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: HomeAppleMapsViewController, context: Context) {
    }
}

struct RouteAppleMapScreen: View {
    var profile: ProfileManager
    @State var routeId: String = "6610a1335cc75bdb59dd72b0" // 6608693c5cc75bdb59dcef06" // "660392ab5cc75bdb59dca01b"
    // @StateObject var mapManager = MapManager()

    @Binding var updated: Bool
    @State var leadSaved = false
    @EnvironmentObject var store: MainStore<UserData>

    @State var showSettings = true

    @ObservedObject var leadManager: LeadManager
    @StateObject var routeManager = RouteManager()
    @StateObject var homeManager = HomeMapManager()

    @State var showFilter = false

    @State var location: CLLocationCoordinate2D = CLLocationCoordinate2D()

    @StateObject var tool = ToolManager()

    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false

    @State var yDragTranslation: CGFloat = 0

    @State var popupVisible = false
    @State var scrollViewHeight: CGFloat = -50
    @State var showInfo = false
    @State var showLeads = false

    @State var selectedMode: String = "driving"
    @State var selectedAvoid: [String] = []

    @StateObject var lassoTool: LassoTool = .init()
    @StateObject var markTool: MarkTool = .init()
    @StateObject var clusterTool: ClusterTool = .init()
    @StateObject var locationTool: LocationTool = .init()
    @StateObject var routeTool: RouteTool = .init()
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                HomeAppleMapsRepresentable(location: $location) { _ in
                    /* lassoTool.setMap(map: map)
                     markTool.setMap(map: map)
                     // clusterTool.setMap(map: map)
                     locationTool.setMap(map: map)
                     routeTool.setMap(map: map)

                     tool.initTool(mode: .lasso, tool: lassoTool)
                     tool.initTool(mode: .marker, tool: markTool)
                     // tool.initTool(mode: .cluster, tool: clusterTool)
                     tool.initTool(mode: .location, tool: locationTool)
                     tool.initTool(mode: .route, tool: routeTool)

                     var longitude = -74.0060
                     var latitude = 40.7128

                     longitude = location.longitude
                     latitude = location.latitude

                     // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
                     map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
                     map.settings.compassButton = true
                     map.settings.zoomGestures = true
                     // map.settings.myLocationButton = true
                     // map.isMyLocationEnabled = true

                     tool.playTool(.location)
                     routeTool.play()
                      */
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(alignment: .topTrailing) {
                    VStack {
                        Button {
                            routeTool.lead?.makePhoneCall()

                        } label: {
                            Image(systemName: "phone.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead?.phone.isEmpty ?? true || routeTool.lead == nil)
                        .padding(10)
                        Button {
                            routeTool.lead?.sendSMS()
                        } label: {
                            Image(systemName: "message.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead?.phone.isEmpty ?? true || routeTool.lead == nil)
                        .padding(10)

                        Button {
                            //routeTool.lead!.openGoogleMaps()
                            
                            if profile.mapApi == .appleMaps {
                                routeTool.lead!.openAppleMaps()
                            } else {
                                routeTool.lead!.openGoogleMaps()
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead == nil)
                        .padding(10)
                    }
                }
                .overlay(alignment: .topLeading) {
                    VStack {
                        Button {
                            routeTool.setBounds()
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

                        Button(action: {
                            showLeads = true
                            // loadApi()
                        }) {
                            Image(systemName: "slider.horizontal.3") // arrow.counterclockwise
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }.padding(10)

                        Button(action: {
                            locationTool.myLocation()
                        }) {
                            Image(systemName: "location.magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }.padding(10)

                        Button(action: {
                            locationTool.follow.toggle()
                        }) {
                            Image(systemName: locationTool.follow ? "car.fill" : "car.front.waves.up.fill")
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
                                routeTool.prevMark()
                            }) {
                                Image(systemName: "arrow.left.circle")

                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.blue)
                                    .padding()

                                // .shadow(radius: 10)
                            }

                            if routeTool.lead != nil {
                                HStack {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .center) {
                                            SuperIcon2(status: Binding(
                                                get: { getStatusType(from: routeTool.lead?.status_id.name ?? "") },
                                                set: { _ in
                                                }
                                            ))
                                            .frame(width: 34, height: 34)

                                            Text("# \(routeTool.lead?.routeOrder ?? 0)")

                                                .font(.headline)
                                                .foregroundColor(Color.accentColor)
                                        }
                                        .padding(3)

                                        VStack(alignment: .leading) {
                                            Text("\(routeTool.lead?.first_name ?? "") \(routeTool.lead?.last_name ?? "")")
                                                .font(.headline)
                                                .foregroundColor(Color.black)

                                            Text("\(routeTool.lead?.street_address ?? "")")
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
                                routeTool.nextMark()
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
                    get: { routeTool.lead ?? LeadModel() },
                    set: { routeTool.lead = $0 }
                ), mode: 2, manager: leadManager, updated: $leadSaved) { result in
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

        .sheet(isPresented: $showLeads) {
            NavigationStack {
                MapLeadList(routeManager: routeManager, selectedMode: $selectedMode, selectedAvoid: $selectedAvoid)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                Task {
                                    let response = try? await routeManager.getDirection(mode: selectedMode, avoid: selectedAvoid)
                                    routeTool.route = response
                                    routeTool.drawRoute(routes: response?.routes ?? [])
                                }

                                showLeads.toggle()
                            } label: {
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
        .onAppear {
            loadApi()
        }

        .onChange(of: leadSaved) { value in

            if value {
                DispatchQueue.main.async {
                    routeTool.updateMarker()
                    leadSaved = false
                }
            }
        }
    }

    func reDraw() {
    }

    func loadApi() {
        Task {
            if routeId != "" {
                if let response = try? await routeManager.routeData(routeId: routeId) {
                    routeManager.route = response
                }

                // return
            }

            if routeId != "" {
                let response = try? await routeManager.getRoute(routeId: routeId)
                if let tool1 = tool.mapTools[.route] as? RouteTool { // routeTool{}
                    tool1.route = response

                    tool1.drawRoute(routes: response?.routes ?? [])
                }
            }
        }
    }
}
