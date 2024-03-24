//
//  RouteView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/2/24.
//

import SwiftUI

struct AddressField<T: AddressProtocol>: View {
    public var label: String
    @State private var searchText = ""
    @State private var searchText2 = ""
    @State private var isModalPresented = false
    @State var value = 0
    @Binding var leadAddress: T

    @StateObject private var location = PlaceManager()
    @ObservedObject private var placeViewModel = PlaceViewModel()
    @State private var locationWaiting = false
    var body: some View {
        HStack {
            TextField(label, text: $leadAddress.street_address)
                // .padding()
                // .textFieldStyle(RoundedBorderTextFieldStyle())
                //.textFieldStyle(RoundedBorderTextFieldStyle())
                .onTapGesture {
                    isModalPresented.toggle()
                }
                .onChange(of: searchText) { _ in

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
            

        }.onReceive(location.$location) { newValue in
            print("one")
            
            if let place = newValue {
                print("two")
                placeViewModel.getPlaceDetailsByCoordinates(latitude: place.latitude, longitude: place.longitude)
            }

        }.onReceive(placeViewModel.$selectedPlace) { newSelectedPlace in
            
            if let placeDetails = newSelectedPlace {
                print("four")
                locationWaiting = false

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

                print(leadAddress)

            
            }
        }
    }
}

struct RouteView01: View {
    @State var AddressFrom: LeadModel = LeadModel()
    @State var AddressTo: LeadModel = LeadModel()

    @State var name: String = ""

    @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    @Binding var leads: [LeadModel]

    var body: some View {
        Form {
            Section("Route Info") {
                TextField("Route Name", text: $name)
                AddressField<LeadModel>(label: "Start Point", leadAddress: $AddressFrom)
                AddressField<LeadModel>(label: "End Point", leadAddress: $AddressTo)
            }

            Section("Leads") {
                List {
                    ForEach(leads.indices, id: \.self) { index in
                        Toggle(isOn: $leads[index].isSelected) {
                            HStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: leads[index].status_id.name))
                                    .frame(width: 34, height: 34)
                                VStack(alignment: .leading) {
                                    Text("\(leads[index].first_name) \(leads[index].last_name)")
                                    Text("\(leads[index].street_address)")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue)) // Puedes ajustar el color del interruptor según tus preferencias
                    }
                }

                /* List {
                     ForEach($lead.leads.indices, id: \.self) { index in
                         Toggle(isOn: $lead.leads[index].isSelected) {
                             HStack {
                                 SuperIconViewViewWrapper(status: getStatusType(from: lead.leads[index].status_id.name))
                                     .frame(width: 34, height: 34)
                                 VStack(alignment: .leading) {
                                     Text("\(lead.leads[index].first_name) \(lead.leads[index].last_name)")
                                     Text("\(lead.leads[index].street_address)")
                                         .foregroundStyle(.gray)
                                 }
                             }
                         }
                         .toggleStyle(SwitchToggleStyle(tint: .blue)) // Puedes ajustar el color del interruptor según tus preferencias
                     }
                 } */
            }

            Button(action: {
                // Acción al hacer clic en el botón
                // Puedes agregar aquí la lógica que se ejecutará cuando se presione el botón "Route it"
            }) {
                Text("Route it")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10) // O cualquier valor que desees para redondear las esquinas
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Route")
        .onAppear {
            let leadQuery = LeadQuery()
            // .add(.limit , "10")
            // .add(.searchKey, "all")
            // .add(.searchValue, "yanny")

            lead.loadAll(query: leadQuery)
        }
    }
}

/*
 #Preview {
     RouteView(leads: [])
 }
 */
#Preview {
    TestCreateLead()
}
