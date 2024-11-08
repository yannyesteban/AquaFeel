//
//  AddressField.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/2/24.
//

import SwiftUI

struct MyAddress: View {
    @State var lead: LeadModel = .init()
    @State var name = "6632"
    var body: some View {
        Section("Address") {
            TextField("Name:",  text: $name)
            /* AddressView<LeadModel>(label: "write a address", leadAddress: $lead) */
            AddressField<LeadModel>(label: "Address", leadAddress: $lead, withPlaceButton: true)
            TextField("Apt / Suite", text: $lead.apt)
            TextField("City", text: $lead.city)
            TextField("State", text: $lead.state)
            HStack {
                TextField("Zip Code", text: $lead.zip)
                TextField("Country", text: $lead.country)
            }
        }
        .onAppear{
            
        }
    }
}

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
    @State var withPlaceButton = true
    
    var body: some View {
        HStack {
            //Text(leadAddress.street_address)
            Image(systemName: "magnifyingglass.circle.fill")
                .foregroundColor(.blue)
                .imageScale(.large)
                .onTapGesture {
                    isModalPresented.toggle()
                }
            Text("...Search Address")
                .foregroundColor(.secondary)
                .lineLimit(1)
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
                    //.presentationDetents([.large, .fraction(0.90), .medium])
                    .presentationContentInteraction(.scrolls)

                    Button("Close") {
                        isModalPresented.toggle()
                    }
                    .padding()
                }
            Spacer()
            if withPlaceButton {
               
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
            
            

        }.onReceive(location.$location) { newValue in
            print("one location.$location")
            
            if let place = newValue {
                print("two location.$location")
                placeViewModel.getPlaceDetailsByCoordinates(latitude: place.latitude, longitude: place.longitude)
            }

        }.onReceive(placeViewModel.$selectedPlace) { newSelectedPlace in
            
            if let placeDetails = newSelectedPlace {
                print("four .onReceive(placeViewModel.$selectedPlace)")
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
/*
struct RouteView01: View {
    @State var AddressFrom: LeadModel = LeadModel()
    @State var AddressTo: LeadModel = LeadModel()

    @State var name: String = ""

    @StateObject var lead = LeadManager()
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

            lead.list(query: leadQuery)
        }
    }
}

 */
/*
 #Preview {
     RouteView(leads: [])
 }
 */
#Preview {
    MyAddress()
    //TestCreateLead()
}
