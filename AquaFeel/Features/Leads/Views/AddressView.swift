//
//  AddressView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/2/24.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String

    var body: some View {
        VStack {
            Image(systemName: "network.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()

            Text(errorMessage)
                .font(.title2)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct ModalView<T: AddressProtocol>: View {
    public var placeholder: String

    @StateObject private var placeManager: PlaceViewModel = PlaceViewModel()

    @State var text: String = ""

    @Binding var leadAddress: T

    var onItemSelected: () -> Void

    @State private var error = false
    @State private var isAPILoading = false
    var body: some View {
        VStack {
            TextField(placeholder, text: $text, onCommit: {
                error = false

                doSearch(text: text)
                // self.placeViewModel.searchPlaces(searchText: text)

            })

            .onChange(of: text, perform: { newSearchText in

                error = false

                searchTimer?.invalidate()

                searchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in

                    doSearch(text: newSearchText)
                    /*
                     DispatchQueue.main.async {
                         if text != ""{
                             print("newSearchText: ", newSearchText)
                             self.placeViewModel.searchPlaces(searchText: newSearchText)
                         }

                     }
                     */
                }

            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if error {
                ErrorView(errorMessage: "network error found!")
                    .transition(.opacity) // Add a transition for a smoother appearance
                Button(action: {
                    doSearch(text: text)
                }) {
                    Text("Retry")
                }
                .padding()
            } else {
                if /* placeViewModel.places.count == 0 && */ text.count >= 3 && isAPILoading {
                    ProgressView("Searching...")
                }
            }

            List(placeManager.places, id: \.placeID) { place in
                Text(place.description)
                    .onTapGesture {
                        placeManager.getPlaceDetails(placeID: place.placeID)
                        onItemSelected()
                    }
            }

            .listStyle(PlainListStyle())
        }
        .padding()
        .navigationTitle("Modal")
        .onAppear {
            text = ""
            doSearch(text: text)
        }
        .onReceive(placeManager.$selectedPlace) { newSelectedPlace in

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
                    } else if component.types.contains("street_number") {
                        // leadAddress.s = component.long_name
                    }
                }

               
            }
        }
    }

    func doSearch(text: String) {
        if text == "" {
            return
        }

        isAPILoading = true
        error = false

        placeManager.doSearchPlaces(searchText: text) { result in

            switch result {
            case let .success(places):

                // Handle successful results (places)
                DispatchQueue.main.async {
                    self.placeManager.places = places
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    self.placeManager.places = []
                }

                // Handle errors with detailed information
                if let userInfo = error._userInfo as? [String: String] {
                    print("Error message:", userInfo["message"] ?? "Unknown error")
                } else {
                    DispatchQueue.main.async {
                        self.error = true
                    }
                }
            }

            DispatchQueue.main.async {
                self.isAPILoading = false
            }
        }
    }
}

struct AddressView<T: AddressProtocol>: View {
    public var label: String
    @State private var searchText = ""
    @State private var searchText2 = ""
    @State private var isModalPresented = false
    @State var value = 0
    @Binding var leadAddress: T

    @StateObject private var location = PlaceManager()
    @ObservedObject private var placeViewModel = PlaceViewModel()

    // @ObservedObject private var placeViewModel = PlaceViewModel()
    var body: some View {
        HStack {
            TextField(label, text: $leadAddress.street_address)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

                .onTapGesture {
                    isModalPresented.toggle()
                }
                .onChange(of: searchText) { v in
                    print(v)
                    isModalPresented.toggle()
                }
                .sheet(isPresented: $isModalPresented) {
                    ModalView<T>(placeholder: label, leadAddress: $leadAddress /* , text: searchText2, leadAddress: $leadAddress */ ) {
                        isModalPresented.toggle()
                    }
                    .presentationDetents([.large, .fraction(0.90), .medium])
                    .presentationContentInteraction(.scrolls)

                    Button("Close") {
                        isModalPresented.toggle()
                    }
                    .padding()
                }
            Button(action: {
                location.start()
            }) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.red)
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
                    placeViewModel.getPlaceDetailsByCoordinates(latitude: place.latitude, longitude: place.longitude)
                }
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
                        } else if component.types.contains("street_number") {
                            // leadAddress.s = component.long_name
                        }
                    }

                  
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
        AddressView<LeadModel>(label: "write a address", leadAddress: $leadAddress) // @State
    }
}

#Preview("testLeadList") {
    LeadListScreen(profile: ProfileManager(), updated: .constant(false))
}

#Preview("Si Funciona") {
    TestAddressView()
}
