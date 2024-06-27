//
//  RouteView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct RouteView: View {
    var profile: ProfileManager
    @ObservedObject var routeManager: RouteManager

    @State var mode: RecordMode = .none
    @State var id: String
    @State var AddressFrom: LeadModel = LeadModel()
    @State var AddressTo: LeadModel = LeadModel()

    @State var name: String = ""

    // @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    @State var leads: [LeadModel] = []

    @State var isShowingSnackbar = false
    @State var showPicker = false
    @State var deleteConfirm = false

    @State var ok = false
    @State var ok2 = false
    @State var error = false
    @State var message = ""
    @State var completed = false

    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Form {
            Section("Route Info") {
                TextField("Route Name", text: $routeManager.route.name)

                AddressRoute<LeadModel>(label: "Start Point", address: $routeManager.route.startingAddress, latitude: $routeManager.route.startingAddressLat, longitude: $routeManager.route.startingAddressLong)
                AddressRoute<LeadModel>(label: "End Point", address: $routeManager.route.endingAddress, latitude: $routeManager.route.endingAddressLat, longitude: $routeManager.route.endingAddressLong)
            }

            Section("Leads") {
                List {
                    ForEach(routeManager.route.leads.indices, id: \.self) { index in
                        NavigationLink(destination: LeadLocationView(profile: profile, lead: routeManager.route.leads[index], location: routeManager.route.leads[index].position)) {
                            Toggle(isOn: $routeManager.route.leads[index].isSelected) {
                                HStack {
                                    SuperIconViewViewWrapper(status: getStatusType(from: routeManager.route.leads[index].status_id.name))
                                        .frame(width: 34, height: 34)
                                    VStack(alignment: .leading) {
                                        Text("\(routeManager.route.leads[index].first_name) \(routeManager.route.leads[index].last_name)")
                                        Text("\(routeManager.route.leads[index].street_address)")
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue)) // Puedes ajustar el color del interruptor según tus preferencias
                        }
                    }
                }
            }
            if mode == .edit {
                Section {
                    Button(action: {
                        deleteConfirm = true
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationBarTitle("Route")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if routeManager.waiting {
                    ProgressView("")

                } else {
                    Button {
                        Task {
                            routeManager.route.leads = routeManager.route.leads.filter { $0.isSelected }

                            try? await routeManager.save(mode: mode)
                            try? await routeManager.list()
                            routeManager.route.id = routeManager.route._id

                            mode = .edit
                            ok = true
                        }

                        // onSave(false)

                    } label: {
                        Label("Save", systemImage: "externaldrive.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showPicker, content: {
            LeadPicker(profile: profile, selectedLeads: $routeManager.route.leads)
        })
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){

                NavigationLink {
                    // RouteMapsScreen(profile: profile, routeId: routeManager.route._id)
                    /* RouteAppleMapScreen(profile: profile, routeId: routeManager.route._id, updated: .constant(false), leadManager: LeadManager()) */
                    RouteMapScreen(profile: profile, routeId: routeManager.route._id, updated: .constant(false), leadManager: LeadManager())
                } label: {
                    Image(systemName: "car.fill")
                }
                .disabled(routeManager.route.id?.isEmpty ?? false)

                NavigationLink {
                    LeadPicker(profile: profile, selectedLeads: $routeManager.route.leads)

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            Task {
                if mode == .edit {
                    try! await routeManager.detail(routeId: id)

                    AddressFrom = LeadModel(street_address: routeManager.route.startingAddress)
                    AddressTo = LeadModel(street_address: routeManager.route.endingAddress)
                } else {
                    routeManager.setNew(leads: leads)
                }
            }
        }
        HStack {
            Button {
                showPicker = true
            } label: {
                Label("Add Leads", systemImage: "person.badge.plus")
                    .font(.title3)
            }.alert(message, isPresented: $ok2) {
                Button("Ok") {
                    completed = true
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
            }
        }
        .alert("Route Created Successfully", isPresented: $ok) {
            Button("Ok") {
                completed = true
            }
        } message: {
            Text("record updated sucessfully")
        }
        .confirmationDialog(
            "Delete record",
            isPresented: $deleteConfirm,
            actions: {
                Button("Delete", role: .destructive) {
                    Task {
                        if let result = try? await routeManager.delete(routeId: id) {
                            try? await routeManager.list()

                            if result.statusCode == 201 {
                                message = result.message
                                ok2 = true
                                // mode = .new
                                routeManager.setNew(leads: [])

                                /* DispatchQueue.main.async {
                                 mode = .new
                                 }
                                 */
                            } else {
                                message = result.message
                                error = true
                            }
                        }
                    }
                }

            },
            message: {
                Text("are you sure to delete record?")
            }
        )
    }
}
