//
//  PlaceViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import Foundation

struct Place: Codable {
    let placeID: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case description
    }
}

struct PlaceAddressComponent: Codable{
    let long_name: String
    let short_name: String
    let types : [String]
}

struct PlaceLocation: Codable {
    let lat: Double
    let lng: Double
}

struct PlaceGeometry: Codable {
    let location: PlaceLocation?
}


struct PlaceDetails: Codable {
    let adr_address: String?
    let formatted_address: String?
    let geometry: PlaceGeometry?
    let vicinity: String?
    let address_components: [PlaceAddressComponent]?
}

struct GeocodeResult: Codable {
    let results: [PlaceDetails]
}


@MainActor
class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var selectedPlace: PlaceDetails?/*{
        didSet {
            // Llamar al cierre de ejecución cuando selectedPlace se actualiza
            print("interesante")
            //onSelectedPlaceUpdated?()
        }
    }*/
    var onSelectedPlaceUpdated: ((_ place: PlaceDetails?,_ error: Error?) -> Void)?
    
    private let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"
    
    func searchPlaces(searchText: String) {
        print(" searchPlaces ", searchText)
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchText)&key=\(apiKey)"//&types=address
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        //print(resultString)
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaceResult.self, from: data)
                        DispatchQueue.main.async {
                            self.places = result.predictions
                            print("searchPlaces OK")
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
        print(" getPlaceDetails ", placeID)
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        //print(resultString)
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaceDetailsResult.self, from: data)
                        DispatchQueue.main.async {
                            self.selectedPlace = result.result
                            print("getPlaceDetails OK")
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
    
    func getPlaceDetailsByCoordinates(latitude: Double, longitude: Double) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    if let resultString = String(data: data, encoding: .utf8) {
                        //print(resultString)
                    }
                    do {
                        let result = try JSONDecoder().decode(GeocodeResult.self, from: data)
                        if let firstResult = result.results.first {
                            DispatchQueue.main.async {
                                self.selectedPlace = firstResult
                                print("getPlaceDetailsByCoordinates OK")
                                self.onSelectedPlaceUpdated?(firstResult, nil)
                                
                                //self.onSelectedPlaceUpdated?(.success(firstResult))
                            }
                        }
                    } catch {
                        //self.onSelectedPlaceUpdated?(nil, .failure(error))
                        print("Error al decodificar datos: \(error.localizedDescription)")
                    }
                } else if let error = error {
                    print("Error en la solicitud: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
}
