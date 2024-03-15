//
//  PlaceViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import Foundation


struct PlaceResult: Codable {
    let predictions: [Place]
}

struct PlaceDetailsResult: Codable {
    let result: PlaceDetails?
}



struct Place: Codable {
    let placeID: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case description
    }
}

struct PlaceAddressComponent: Codable {
    let long_name: String
    let short_name: String
    let types: [String]
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
    @Published var selectedPlace: PlaceDetails? /* {
                                                 didSet {
                                                 // Llamar al cierre de ejecución cuando selectedPlace se actualiza
                                                 print("interesante")
                                                 //onSelectedPlaceUpdated?()
                                                 }
                                                 } */
    var onSelectedPlaceUpdated: ((_ place: PlaceDetails?, _ error: Error?) -> Void)?
    
    private let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"
    
    func searchPlaces(searchText: String) {
        guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error")
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedSearchText)&key=\(apiKey)&types=address"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    /*
                     if let resultString = String(data: data, encoding: .utf8) {
                     print(resultString)
                     }
                     */
                    do {
                        let result = try JSONDecoder().decode(PlaceResult.self, from: data)
                        DispatchQueue.main.async {
                            self.places = result.predictions
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
    
    func getPlaceDetails(placeID: String) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(PlaceDetailsResult.self, from: data)
                        DispatchQueue.main.async {
                            self.selectedPlace = result.result
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
    
    func getPlaceDetailsByCoordinates(latitude: Double, longitude: Double) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(GeocodeResult.self, from: data)
                        if let firstResult = result.results.first {
                            DispatchQueue.main.async {
                                print("que paso", firstResult)
                                self.selectedPlace = firstResult
                                
                                self.onSelectedPlaceUpdated?(firstResult, nil)
                            }
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
    
    func decode<T: AddressProtocol>(placeDetails: PlaceDetails?, leadAddress:T)->T{
        var leadAddress = leadAddress
        
        if let placeDetails = placeDetails {
            
            
            leadAddress.street_address = placeDetails.formatted_address ?? ""
            leadAddress.latitude = String(placeDetails.geometry?.location?.lat ?? 0.0)
            leadAddress.longitude = String(placeDetails.geometry?.location?.lng ?? 0.0)
            
            for component in placeDetails.address_components ?? [] {
                if component.types.contains("country") && component.types.contains("political") {
                    leadAddress.country = component.long_name
                } else if component.types.contains("administrative_area_level_1") && component.types.contains("political") {
                    leadAddress.state = component.short_name
                } else if component.types.contains("administrative_area_level_2") && component.types.contains("political") {
                    leadAddress.city = component.short_name
                } else if component.types.contains("postal_code") {
                    leadAddress.zip = component.long_name
                }else if component.types.contains("street_number") {
                    //leadAddress.s = component.long_name
                }
            }
            
            print(leadAddress)
            
        }else {
            
            print("selectedPlace is nil")
        }
        
        return leadAddress
    }
    
    
    func getDetails(placeID: String) async throws -> PlaceDetails? {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL) // Manejo de errores si la URL es inválida
        }
        
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(PlaceDetailsResult.self, from: data)
            return result.result
        } catch {
            throw error // Propaga cualquier error que ocurra durante la solicitud o decodificación
        }
    }
    
    
    func decodeDetails(placeDetails: PlaceDetails) -> AddressModel {
        //var leadAddress: AddressModel? // Cambiado a AddressModel para permitir la asignación directa
        
        
        var  leadAddress = AddressModel()
        
        leadAddress.street_address = placeDetails.formatted_address ?? ""
        leadAddress.latitude = String(placeDetails.geometry?.location?.lat ?? 0.0)
        leadAddress.longitude = String(placeDetails.geometry?.location?.lng ?? 0.0)
        
        for component in placeDetails.address_components ?? [] {
            if component.types.contains("country") && component.types.contains("political") {
                leadAddress.country = component.long_name
            } else if component.types.contains("administrative_area_level_1") && component.types.contains("political") {
                leadAddress.state = component.short_name
            } else if component.types.contains("administrative_area_level_2") && component.types.contains("political") {
                leadAddress.city = component.short_name
            } else if component.types.contains("postal_code") {
                leadAddress.zip = component.long_name
            }
        }
        
       
        
        
        
        return leadAddress
    }
    
}
