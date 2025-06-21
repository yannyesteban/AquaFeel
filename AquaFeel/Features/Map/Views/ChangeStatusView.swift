//
//  ChangeStatusView.swift
//  AquaFeel
//
//  Created by Yanny Nuñez Jimenez on 4/18/25.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct StatusResponse: Codable {
    let count: Int
    let list: [StatusId]
}

struct NavigationButton: View {
    var imageName: String
    var label: String
    var badge: Int?
    var destination: () -> any View

    var body: some View {
        NavigationLink(destination: AnyView(destination())) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)

                Text(label)
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(1.0))
                .border(Color.gray, width: 1)
        )
        .foregroundColor(.gray)
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 0)
        )
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 3, y: 3)

        .overlay(
            badge.map { count in

                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Circle().fill(Color.red))
                    .offset(x: 2, y: -14)
            }
            , alignment: .topTrailing)
    }
}

struct ButtonWithAction: View {
    var imageName: String
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text(label)
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(1.0))
                .border(Color.gray, width: 1)
        )
        .foregroundColor(.gray)
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 0)
        )
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 3, y: 3)
    }
}

struct BorderButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10) // Espaciado alrededor del botón
            .background(
                RoundedRectangle(cornerRadius: 5) // Aplica la forma del botón al fondo
                    .fill(Color.white.opacity(1.0)) // Fondo blanco
                    .border(Color.gray, width: 1) // Borde rojo con el mismo radio que el fondo
            )
            .foregroundColor(.gray) // Color del contenido del botón
            .cornerRadius(0) // Redondea las esquinas del contenido del botón
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 0) // Color y grosor del borde
            )
            .shadow(color: .gray.opacity(!configuration.isPressed ? 0.5 : 0), radius: 5, x: 3, y: 3)
        // .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

struct SelectLeadView: View {
    @ObservedObject var leadManager: LeadManager
    
    var body: some View {
        List {
            ForEach($leadManager.filteredLeads, id: \.self) { $lead in
                
                if isProblematicVersion() {
                    HStack {
                        SuperIconViewViewWrapper(status: getStatusType(from: lead.status_id.name))
                            .frame(width: 34, height: 34)
                        VStack(alignment: .leading) {
                            Text("\(lead.first_name) \(lead.last_name)")
                            Text(lead.street_address)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                } else {
                    Toggle(isOn: $lead.isSelected) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: lead.status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(lead.first_name) \(lead.last_name)")
                                Text(lead.street_address)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                }
                
            }
        }
        /*List {
         ForEach(leadManager.filteredLeads.indices, id: \.self) { index in
         
         Toggle(isOn: $leadManager.filteredLeads[index].isSelected) {
         HStack {
         SuperIconViewViewWrapper(status: getStatusType(from: leadManager.filteredLeads[index].status_id.name))
         .frame(width: 34, height: 34)
         VStack(alignment: .leading) {
         Text("\(leadManager.filteredLeads[index].first_name) \(leadManager.filteredLeads[index].last_name)")
         Text("\(leadManager.filteredLeads[index].street_address)")
         .foregroundStyle(.gray)
         }
         }
         }
         .toggleStyle(SwitchToggleStyle(tint: .blue))
         }
         }*/
    }
    private func isProblematicVersion() -> Bool {
            let version = UIDevice.current.systemVersion
            return version.hasPrefix("18.3")
        }
    
}

struct ChangeStatusView: View {
    @ObservedObject var leadManager: LeadManager

    @State var statusId: StatusId = .init()
    @State var statusList: [StatusId] = []
    // @Binding var leads: [LeadModel]
    @State var isShowingSnackbar = false
    @State var statusConfirm = false
    @State var showErrorMessage = false
    // @State var showMessage = false
    @State var errorMessage = "Error"
    @State private var showAlert = false
    var body: some View {
        Form {
            Section("Select Status") {
                HStack {
                    LeadStatusView(status: $statusId, statusList: statusList)
                }
            }
            Section("Leads") {
                SelectLeadView(leadManager: leadManager)
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to change the status?"),
                primaryButton: .destructive(Text("Change")) {
                    Task {
                        try? await leadManager.bulkStatusUpdate(statusId: statusId)
                    }
                },
                secondaryButton: .cancel()
            )
        }

        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isShowingSnackbar {
                    ProgressView("")

                } else {
                    Button {
                        if statusId._id.isEmpty {
                            errorMessage = "you would select a status!"
                            showErrorMessage = true
                            return
                        }

                        showAlert = true

                    } label: {
                        Label("Save", systemImage: "externaldrive.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

struct ChangeUserView: View {
    @ObservedObject var leadManager: LeadManager
    // @ObservedObject var manager: LeadsManager
    @ObservedObject var adminManager: AdminManager

    @State var owner: CreatorModel = .init()

    // @State var statusList: [StatusId] = []
    @State var isShowingSnackbar = false
    @State var statusConfirm = false
    @State var showErrorMessage = false
    @State var showMessage = false
    @State var errorMessage = "Error"
    @State private var showAlert = false

    var body: some View {
        Form {
            Section("Select User") {
                HStack {
                    OwnerView(text: "Select User", owner: $owner, adminManager: adminManager)
                }
            }

            Section("Leads") {
                SelectLeadView(leadManager: leadManager)
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to change the user?"),
                primaryButton: .destructive(Text("Change")) {
                    Task {
                        try? await leadManager.bulkAssignToSeller(owner: owner)
                    }
                },
                secondaryButton: .cancel()
            )
        }

        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isShowingSnackbar {
                    ProgressView("")

                } else {
                    Button {
                        if owner._id.isEmpty {
                            errorMessage = "you would select a user!"
                            showErrorMessage = true
                            return
                        }
                        showAlert = true

                    } label: {
                        Label("Save", systemImage: "externaldrive.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

struct DeleteLeadsView: View {
    @ObservedObject var leadManager: LeadManager
    // @ObservedObject var manager: LeadsManager
    // @State var leads: [LeadModel] = []
    // @State var statusList: [StatusId] = []
    @State var isShowingSnackbar = false
    @State var statusConfirm = false
    @State var showErrorMessage = false
    @State var showMessage = false
    @State var errorMessage = "Error"

    // @StateObject var manager = LeadsManager()

    @State private var showAlert = false
    var body: some View {
        Form {
            Section("Leads") {
                SelectLeadView(leadManager: leadManager)
            }
        }

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("Delete")) {
                    Task {
                        try? await leadManager.deleteBulk()
                    }
                },
                secondaryButton: .cancel()
            )
        }

        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isShowingSnackbar {
                    ProgressView("")

                } else {
                    Button {
                        showAlert = true

                    } label: {
                        Label("Save", systemImage: "trash.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }
}
