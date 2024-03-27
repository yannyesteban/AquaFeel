//
//  AddressView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 8/2/24.
//

import SwiftUI
import GoogleMaps
//import GooglePlaces










struct LocationTextField: View {
    @Binding var text: String
    @StateObject private var viewModel = PlaceManager()
    @State private var isLocationVisible = false
    var body: some View {
        HStack {
            TextField("Ingrese texto.", text: $text)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            Button(action: {
                viewModel.start()
                viewModel.requestLocation()
                
                isLocationVisible.toggle()
            }) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                    .padding(8)
            }
        }
        
        
            Group {
                if let location = viewModel.location {
                    Text("\(location.latitude)")
                        .padding(.horizontal, 16)
                        .opacity(isLocationVisible ? 1.0 : 0.0) // Controla la opacidad del Text
                        //.animation(.easeInOut(duration: 0.5)) // Agrega una animación a la opacidad
                }
            }
        
       
        
    }
}

struct ClearableTextField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Ingrese texto", text: $text)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}




struct AutocompleteList: View {
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { index in
                Text("Opción \(index)")
                    .padding(.vertical, 10)
                    .onTapGesture {
                        // Realizar la acción cuando se selecciona una opción
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .frame(maxHeight: 200) // Altura máxima del autocompletado
    }
}


var searchTimer: Timer?
struct AddressViewPrevies: View {
    @State private var searchText = ""
    @State private var places = [Place]()
    
    @StateObject private var viewModel = PlaceManager()
    @State private var locationText = ""
    @State private var showAutocomplete = false
    
    @State private var isModalPresented = false
    
    
    
    var body: some View {
        
        VStack {
            
            TextField("Escribe una dirección", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onTapGesture {
                    // Muestra la pantalla modal cuando el TextField obtiene el foco
                    isModalPresented = true
                }
                
            TextField("Escribe una dirección", text: $searchText, onCommit: {
                searchPlaces()
                showAutocomplete = !searchText.isEmpty
            })
            .padding()
            
            if showAutocomplete {
                AutocompleteList()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onTapGesture {
                                    // Ocultar el autocompletado al tocar fuera de la lista
                                    showAutocomplete = false
                                }
                        }
                            .ignoresSafeArea(.keyboard, edges: .all)
                    )
            }
            
            
            TextField("Escribe una dirección 3.0", text: $searchText)
                .onChange(of: searchText, perform: {newSearchText in
                    searchTimer?.invalidate()
                    // Inicia un nuevo temporizador con un retraso de 1.5 segundos
                    searchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                        // Realiza la búsqueda después del retraso
                        searchPlaces()
                    }
                    
                })
                .padding()
            ZStack {
                List(places, id: \.placeID) { place in
                    Text(place.description).onTapGesture {
                        getPlaceDetails(placeID: place.placeID)
                    }
                }
            }
            LocationTextField(text: $locationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onReceive(viewModel.$location) { currentLocation in
                    locationText = "Ubicación actual: Latitud \(currentLocation?.latitude), Longitud \(currentLocation?.longitude)"
                    //locationText = String(currentLocation!.latitude)
                }
            
            if let currentLocation = viewModel.location {
                Text("Ubicación actual: Latitud \(currentLocation.latitude), Longitud \(currentLocation.longitude)")
                    .padding()
            }
            ClearableTextField(text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Texto ingresado: \(searchText)")
                .padding()
            
            if let location = viewModel.location {
                Text("Latitud: \(location.latitude), Longitud: \(location.longitude)")
            } else {
                Text("Obteniendo ubicación...")
            }
            
            
        }.onAppear {
            //requestLocation()
        }
    }
    
    func requestLocation() {
        let locationManager = CLLocationManager()
        //locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func searchPlaces() {
        
        let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchText)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        print(resultString)
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaceResult.self, from: data)
                        DispatchQueue.main.async {
                            self.places = result.predictions
                        }
                    } catch {
                        print("Error al decodificar datos: \(error.localizedDescription)")
                    }
                } else if let error = error {
                    print("Error en la solicitud: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
    
    func getPlaceDetails(placeID: String) {
        let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"
        
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        print(resultString)
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaceDetailsResult.self, from: data)
                        if let location = result.result?.geometry?.location {
                            let latitude = location.lat
                            let longitude = location.lng
                            print("Coordenadas: Latitud \(latitude), Longitud \(longitude)")
                        }
                    } catch {
                        print("Error al decodificar datos: \(error.localizedDescription)")
                    }
                } else if let error = error {
                    print("Error en la solicitud: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
}


#Preview {
    AddressViewPrevies()
}

