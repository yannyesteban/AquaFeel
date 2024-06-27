//
//  ModalView3.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct ModalView3: View {
    public var placeholder: String
    
    @ObservedObject private var placeViewModel = PlaceViewModel()
    @ObservedObject var addressManager: AddressManager
    @State var text: String = ""
    // @Binding var address: AddressModel
    
    var onItemSelected: () -> Void
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $text, onCommit: {
                self.placeViewModel.searchPlaces(searchText: text)
                
            })
            
            .onChange(of: text, perform: { newSearchText in
                
                searchTimer?.invalidate()
                
                searchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    
                    DispatchQueue.main.async {
                        if text != "" {
                            self.placeViewModel.searchPlaces(searchText: newSearchText)
                        }
                    }
                }
                
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            List(placeViewModel.places, id: \.placeID) { place in
                Text(place.description)
                    .onTapGesture {
                        placeViewModel.getPlaceDetails(placeID: place.placeID)
                        onItemSelected()
                        
                        Task {
                            let x = try await placeViewModel.getDetails(placeID: place.placeID)
                            
                            if let x = x {
                                addressManager.address = placeViewModel.decodeDetails(placeDetails: x)
                            }
                        }
                    }
            }
            
            .listStyle(PlainListStyle())
        }
        .padding()
        .navigationTitle("Modal")
        .onAppear {
            text = ""
        }
        .onReceive(placeViewModel.$selectedPlace) { _ in
            /*
             if let placeDetails = newSelectedPlace {
             
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
             
             }*/
        }
    }
}
