//
//  RouteControler.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/3/24.
//

import SwiftUI

class DirectionManager: ObservableObject {
    @Published var origin = ""
    @Published var destination = ""
    var waypoints = "3100 Breton Drive, Denton"
    let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"

    init() {
        let origin = "6632 Alderbrook Dr, Denton, TX 76210, EE. UU."
        let destination = "Walmart Neighborhood Market, 3930 Teasley Ln, Denton, TX 76210, Estados Unidos"

        search(origin: origin, destination: destination)
    }

    func search(origin: String, destination: String) {
        guard let origin = origin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error")
            return
        }

        guard let destination = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error")
            return
        }

        guard let waypoints = waypoints.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error")
            return
        }

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(apiKey)&waypoints=\(waypoints)"
        print(urlString)
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        /// print(resultString)
                    }

                    do {
                        let result = try JSONDecoder().decode(RouteResponse.self, from: data)
                        DispatchQueue.main.async {
                            print("result.status", result.status)
                            prettyPrint(result)
                            // self.places = result.predictions
                        }
                    } catch {
                        print("Error decoding: \(error.localizedDescription)")
                    }

                } else if let error = error {
                    print("Error in request: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
}

import GoogleMaps // Asegúrate de haber importado el framework de Google Maps en tu proyecto
import UIKit

class RouterMaps: UIViewController {
    let map = GMSMapView()

    // var mode:Bool = false

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        print("loadView****** * * ** * * * * * * ")
        print(" loadView() ")
        super.loadView()

        // withLatitude: 33.1510323, longitude: -97.09571889999999
        let longitude = -97.09571889999999 // -74.0060 // -122.008972 //-122.008972
        let latitude = 33.1510323 // 40.7128 // 39.2750209// 37.33464379999999

        // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
        map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
        map.settings.compassButton = true
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        view = map

        map.delegate = self

        drawRoute()
    }

    func drawRoute() {
        // Polyline points from JSON
        let polylinePoints = "ioiiE`_soQkAQiACi@?sBZ`@nD@~AAl@WG{Ag@oAy@sAqAqDgDq@k@cA{@uB{AwGwD_Cw@wB]uDGoA@GrJL^D`ABd@C`EC~BPAd@?pECtCEdB@dAHVPfBxAp@p@`Az@VZL^Lt@DtA?vDBdBEf@[|B_@nB[j@YLSBQGOCUFSKYQMQN[OZLPPN@HFZAZDTFJLJN@\\p@x@`FDfAC~BqFBcCBsBNeDD{GJsDFq@Fs@NsA`@_Bt@cAr@_@XHNPd@@R@\\AbCb@AnBAT?XEXIRM`@g@\\a@"

        let path = GMSPath(fromEncodedPath: polylinePoints)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blue
        polyline.strokeWidth = 5.0
        polyline.map = map
    }

    override func viewDidLoad() {
        print(" viewDidLoad() ")
        print("viewDidLoad.........................................")
        super.viewDidLoad()

        let customGestureRecognizer = DragDropGestureRecognizer(target: self, action: #selector(handleCustomGesture(_:)))

        // Agregar el gesto a la vista
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
        print("arenita playita 2.0")
    }
}

struct RouterMapsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RouterMaps {
        return RouterMaps()
    }

    func updateUIViewController(_ uiViewController: RouterMaps, context: Context) {
        // No se necesita hacer nada aquí para este ejemplo.
    }
}

struct RouteMapsScreen: View {
    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false

    @State var yDragTranslation: CGFloat = 0

    @State var popupVisible = false
    @State var scrollViewHeight: CGFloat = -50

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                RouterMapsView()

                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        VStack {
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
                            Button(action: {
                                print("ok")
                            }) {
                                Image(systemName: "folder.fill")
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
                    Spacer()
                    VStack(alignment: .leading) {
                        Spacer()
                        Button(action: {
                            print("ok")
                        }) {
                            Image(systemName: "3.circle") // Icono del botón (cambia esto por tu icono)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30) // Tamaño del icono
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue) // Color de fondo del botón
                                .clipShape(Circle()) // Forma circular del botón
                                .shadow(radius: 10) // Sombra
                        }
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Button(action: {
                            print("ok")
                        }) {
                            Image(systemName: "2.circle") // Icono del botón (cambia esto por tu icono)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30) // Tamaño del icono
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue) // Color de fondo del botón
                                .clipShape(Circle()) // Forma circular del botón
                                .shadow(radius: 10) // Sombra
                        }
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Button(action: {
                            var direction = DirectionManager()
                        }) {
                            Image(systemName: "1.circle") // Icono del botón (cambia esto por tu icono)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30) // Tamaño del icono
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue) // Color de fondo del botón
                                .clipShape(Circle()) // Forma circular del botón
                                .shadow(radius: 10) // Sombra
                        }
                    }
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

            }.frame(width: .infinity)
                .background(.orange)
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
            print(123456)
        }
    }
}

struct ContentView_Previews1010: PreviewProvider {
    static var previews: some View {
        RouteMapsScreen()
    }
}
