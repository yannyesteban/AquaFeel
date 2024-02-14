//
//  AddressView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import SwiftUI

struct ModalView<T: AddressProtocol>: View {
    public var placeholder:String
    
    @ObservedObject private var placeViewModel = PlaceViewModel()
    
    @State var text : String = ""
    @Binding var leadAddress: T
    
    //@State private var placesCount = 0
    
    
    var onItemSelected: () -> Void
    
    var body: some View {
        VStack {
            
            TextField(placeholder, text: $text, onCommit: {
                print(text)
                self.placeViewModel.searchPlaces(searchText: text)
                
            })
            
            .onChange(of: text, perform: {newSearchText in
                //leadAddress.first_name = "Panda"
                print("onChange", newSearchText)
                searchTimer?.invalidate()
                
                searchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    //self.placeViewModel.searchPlaces(searchText: newSearchText)
                    DispatchQueue.main.async {
                        if text != ""{
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
                    }
            }
            
            .listStyle(PlainListStyle())
            
            
            Button("Test") {
                //placesCount = placeViewModel.places.count
                placeViewModel.getPlaceDetailsByCoordinates(latitude: 33.9982601, longitude: -118.1696825)
            }
            
            .padding()
            
            
        }
        .padding()
        .navigationTitle("Modal")
        .onAppear{
            text = ""
        }
        .onReceive(placeViewModel.$selectedPlace) { newSelectedPlace in
            
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
                
                print(leadAddress)
                
            }else {
                
                print("selectedPlace is nil")
            }
        }
        /*
         .onAppear(placeViewModel.$selectedPlace?){ place in
         print(place.geometry?.location?.lat)
         }
         */
    }
}

struct AddressView<T: AddressProtocol>: View {
    public var label:String
    @State private var searchText = ""
    @State private var searchText2 = ""
    @State private var isModalPresented = false
    @State var value = 0
    @Binding var leadAddress: T
    
    @StateObject private var location = LocationViewModel()
    @ObservedObject private var placeViewModel = PlaceViewModel()
    
    
    //@ObservedObject private var placeViewModel = PlaceViewModel()
    var body: some View {
        HStack {
            TextField(label, text: $leadAddress.street_address)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
                .onTapGesture {
                    
                    isModalPresented.toggle()
                }
                .onChange(of: searchText){ v in
                    print(v)
                    isModalPresented.toggle()
                }
                .sheet(isPresented: $isModalPresented) {
                    
                    
                    ModalView<T>(placeholder: label, leadAddress: $leadAddress /*, text: searchText2, leadAddress: $leadAddress*/){
                        isModalPresented.toggle()
                    }
                        .presentationDetents([ .large,.fraction(0.90), .medium])
                        .presentationContentInteraction(.scrolls)
                    
                    Button("Close") {
                        isModalPresented.toggle()
                        
                    }
                    .padding()
                    
            }
            Button(action: {
                //viewModel.requestLocation()
                //print(999)
                //leadAddress.street_address = "caracas 1012"
                location.start()
            }) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                    .padding(8)
            }
        }
        
        
        
        
        TextField("Apt / Suite", text: $leadAddress.apt)
        TextField("City", text: $leadAddress.city)
        TextField("State", text: $leadAddress.state)
        TextField("Zip Code", text: $leadAddress.zip)
        TextField("Country", text: $leadAddress.country)
        
            .onReceive(location.$location) { newValue in
                
                if let place = newValue {
                    print("El valor de count ha cambiado a \(newValue?.latitude)")
                    
                    placeViewModel.getPlaceDetailsByCoordinates(latitude: place.latitude, longitude: place.longitude)
                }
                
            }
            .onReceive(placeViewModel.$selectedPlace){newSelectedPlace in
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
                    
                    print(leadAddress)
                    
                }else {
                    
                    print("selectedPlace is nil")
                }
            }
        
        /*
         TextField("Phone2", text: Binding(
         get: { lead.phone2 ?? "" },
         set: { lead.phone2 = $0 }
         ))
         */
        
        
        
    }
}

struct TestAddressView: View {
    
    @State var leadAddress: LeadModel = LeadModel()
    
    
    var body: some View {
        AddressView<LeadModel>(label: "write a address", leadAddress: $leadAddress) //@State
    }
}

#Preview("testLeadList") {
    testLeadList()
}


#Preview ("Si Funciona"){
    TestAddressView()
}
