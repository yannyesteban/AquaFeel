//
//  AddressRoute.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct AddressRoute<T: AddressProtocol>: View {
    public var label: String
    
    @Binding var address: String
    @Binding var latitude: String
    @Binding var longitude: String
    
    @State private var searchText = ""
    @State private var searchText2 = ""
    @State private var isModalPresented = false
    @State var value = 0
    // @Binding var leadAddress: T
    
    @StateObject private var location = PlaceManager()
    @StateObject private var placeViewModel = PlaceViewModel()
    @State private var locationWaiting = false
    
    // @State var address = AddressModel()
    
    @StateObject var addressManager = AddressManager()
    var body: some View {
        HStack {
            TextField(label, text: $address)
            
                .onTapGesture {
                    isModalPresented.toggle()
                }
                .onChange(of: searchText) { _ in
                    
                    isModalPresented.toggle()
                }
                .sheet(isPresented: $isModalPresented) {
                    ModalView3(placeholder: label, addressManager: addressManager) {
                        isModalPresented.toggle()
                    }
                    .presentationDetents([.large, .fraction(0.90), .medium])
                    .presentationContentInteraction(.scrolls)
                    
                    Button("Close") {
                        isModalPresented.toggle()
                    }
                    .padding()
                }
            
            if locationWaiting {
                ProgressView("")
                    .padding(.leading, 14)
                    .padding(.top, 2)
                
            } else {
                Button(action: {
                    // location.location = nil
                    locationWaiting = true
                    location.start()
                    
                }) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                    
                        .imageScale(.large)
                        .padding(.leading, 10)
                }
            }
        }
        
        .onReceive(addressManager.$address) { new in
            DispatchQueue.main.async {
                address = new.street_address
                latitude = new.latitude
                longitude = new.longitude
            }
        }
        
        .onReceive(location.$location) { newValue in
            
            if let place = newValue {
                latitude = String(place.latitude)
                longitude = String(place.longitude)
                
                placeViewModel.getPlaceDetailsByCoordinates(latitude: place.latitude, longitude: place.longitude)
            }
            
        }.onReceive(placeViewModel.$selectedPlace) { newSelectedPlace in
            
            if let placeDetails = newSelectedPlace {
                locationWaiting = false
                
                latitude = String(placeDetails.geometry?.location?.lat ?? 0.0)
                longitude = String(placeDetails.geometry?.location?.lng ?? 0.0)
                address = placeDetails.formatted_address ?? ""
            }
        }
    }
}
