//
//  PathOptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 6/2/24.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct StatusResponse: Codable {
    let count: Int
    let list: [StatusId]
}

class PathManager: ObservableObject {
}

class StatusManager: ObservableObject {
    @Published var statusList: [StatusId] = []
    @Published var lastStatus: StatusId?
    @Published var lastStatusType: StatusType?

    init() {
        Task {
            try? await list()
        }
    }

    func list() async throws {
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: "", params: nil)

        do {
            let response: StatusResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                self.statusList = response.list
            }

        } catch {
            throw error
        }
    }
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
    @ObservedObject var manager: LeadsManager
    
    
    var body: some View {
        
        List {
            ForEach(manager.leads.indices, id: \.self) { index in
                
                Toggle(isOn: $manager.leads[index].isSelected) {
                    HStack {
                        SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                            .frame(width: 34, height: 34)
                        VStack(alignment: .leading) {
                            Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                            Text("\(manager.leads[index].street_address)")
                                .foregroundStyle(.gray)
                                
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue)) 
            }
        }
    }
}

struct ChangeStatusView: View {
    @ObservedObject var manager: LeadsManager
    @Binding var statusId: StatusId
    @State var statusList: [StatusId] = []
    @Binding var leads: [LeadModel]
    @State var isShowingSnackbar = false
    @State var statusConfirm = false
    @State var showErrorMessage = false
    //@State var showMessage = false
    @State var errorMessage = "Error"
    @State private var showAlert = false
    var body: some View {
        Form {
            Section("Select Status") {
                HStack {
                    MyStatus(status: $manager.statusId, statusList: statusList)
                }
            }
            Section("Leads") {
                SelectLeadView(manager: manager)
                
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
                    Task{
                        try? await manager.bulkStatusUpdate()
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
                        if manager.statusId._id.isEmpty {
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
    @ObservedObject var manager: LeadsManager
    @Binding var owner: CreatorModel
    @Binding var leads: [LeadModel]
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
                    OwnerView(text: "Select User", owner: $manager.owner)
                }
            }
            
            Section("Leads") {
                SelectLeadView(manager: manager)
                
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
                    Task{
                        try? await manager.bulkAssignToSeller()
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
                        
                        if manager.owner._id.isEmpty {
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
    @ObservedObject var manager: LeadsManager
    @State var leads: [LeadModel] = []
    // @State var statusList: [StatusId] = []
    @State var isShowingSnackbar = false
    @State var statusConfirm = false
    @State var showErrorMessage = false
    @State var showMessage = false
    @State var errorMessage = "Error"
    @State var x: Bool = true
    //@StateObject var manager = LeadsManager()
    
    @State private var showAlert = false
    var body: some View {
        Form {
            
            Section("Leads") {
                SelectLeadView(manager: manager)
                
            }
            
        }
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("Delete")) {
                    Task{
                        try? await manager.deleteBulk()
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

struct PathOptionView: View {
    var profile: ProfileManager
    @StateObject var routeManager = RouteManager()
    // @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    @State private var groupedLeads: [String: Int] = [:] // Propiedad para almacenar los resultados
    @Binding var leads: [LeadModel]
    @Binding var path: GMSMutablePath

    @State private var selectedItems: Set<String> = []
    @State var filteredLeads: [LeadModel] = []

    @State var leadsInsidePath: [LeadModel] = []

    @State var status: StatusId? = nil

    @State var sta: StatusType = .none
    @State private var isModalPresented = false

    @StateObject var statusManager = StatusManager()
    var statusList: [StatusId] = []
    @State var statusConfirm = false
    @State var isUserChange = false
    @State var userId = "none"
    @State var statusId = StatusId()

    // @Binding var owner: CreatorModel
    @StateObject private var viewModel = CreatorViewModel()
    @State var owner = CreatorModel()
    @StateObject var leadsManager = LeadsManager()
    @ObservedObject var leadManager: LeadManager
    @Binding var updated: Bool
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Lasso Options")
                    .padding(.vertical, 20)
                /* Text(selectedItems.joined(separator: ", "))
                 .font(.body)
                 .padding() */

                if !leadsInsidePath.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            Spacer()
                            ForEach(Array(groupedLeads.keys), id: \.self) { statusName in
                                let count = groupedLeads[statusName] ?? 0

                                VStack {
                                    SuperIconViewViewWrapper(status: getStatusType(from: statusName))
                                        .frame(width: 30, height: 30)
                                        // .colorMultiply(Color.white)
                                        // .imageModifier(Color.gray)
                                        // .imageModifier(.grayscale(0.8))
                                        .grayscale(!selectedItems.contains(statusName) ? 0.9 : 0.0)
                                        // .brightness(selectedItems.contains(statusName) ? 0.5 : 5)
                                        .brightness(!selectedItems.contains(statusName) ? 0.3 : 0.0)
                                    if selectedItems.contains(statusName) {
                                        Text("\(count)")
                                    } else {
                                        Text("0")
                                            .brightness(0.1)
                                    }
                                    // Text("\(count)")
                                }
                                .padding(5)
                                .onTapGesture {
                                    // Acción al hacer tap en el elemento
                                    toggleSelection(statusName)

                                    // print("Tapped on \(statusName)")
                                }
                                /* .overlay(
                                 RoundedRectangle(cornerRadius: 8)
                                 .stroke(selectedItems.contains(statusName) ? Color.blue : Color.gray, lineWidth: 2)
                                 )
                                 .background(
                                 RoundedRectangle(cornerRadius: 8)
                                 .fill(selectedItems.contains(statusName) ? Color.gray.opacity(0.2) : Color.clear)
                                 ) */
                            }

                            Spacer()
                        }
                    }
                    .padding(20)
                } else {
                    Text("No Data")
                }

                HStack {
                    NavigationButton(imageName: "app.connected.to.app.below.fill", label: "Route", badge: filteredLeads.count) {
                        // RouteView01(leads: $filteredLeads)
                        RouteView(profile: profile, routeManager: routeManager, mode: .new, id: "0", leads: filteredLeads)
                    }
                    NavigationButton(imageName: "person.fill.checkmark", label: "Owner") {
                        ChangeUserView(manager: leadsManager, owner: $owner, leads: $filteredLeads)
                    }.disabled(profile.role == "SELLER")

                    NavigationButton(imageName: "star.fill", label: "Status") {
                        // print("Status ....")
                        ChangeStatusView(manager: leadsManager, statusId: $statusId, statusList: statusManager.statusList,leads: $filteredLeads)
                    }
                    NavigationButton(imageName: "trash.fill", label: "Delete") {
                        
                        DeleteLeadsView(manager: leadsManager)
                            /*.onAppear{
                                var clonedLeads = Array(filteredLeads)
                                leadsManager.leads = clonedLeads
                            }*/
                    }
                    /*
                    ButtonWithAction(imageName: "trash.fill", label: "Delete") {
                        print("Delete ....")
                        loadDataAndProcess()
                    }

                   

                     List(filteredLeads, id: \.id) { lead in
                         Text(lead.status_id.name)
                         // print (lead.status_id.name)
                         // Tu contenido de vista para cada elemento
                     }
                     */
                }
                Text("Total Leads \(leads.count)")
            }
            .onChange(of: filteredLeads){ leads in
                leadsManager.leads = leads
                
            }
            .onChange(of: leadsManager.updated){ value in
                updated = value
                print("bye update....", value)
            }
            .onDisappear{
                print("bye update....1.0 ", leadsManager.updated)
                if leadsManager.updated {
                    print("bye update")
                    //leadManager.search()
                }
                print("bye")
            }
            
            .onAppear {
                
                routeManager.userId = profile.userId
                /*
                  path.removeAllCoordinates()

                 path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -125.0000000))
                 path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -66.9345703))
                 path.add(CLLocationCoordinate2D(latitude: 24.396308, longitude: -66.9345703))
                 path.add(CLLocationCoordinate2D(latitude: 24.396308, longitude: -125.0000000))
                 path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -125.0000000))

                 // Otros puntos para mejorar la forma del path
                 path.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                 path.add(CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
                 path.add(CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298))
                 path.add(CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
                 path.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                 */

                leadsInsidePath = []
                loadDataAndProcess()
            }
            .onChange(of: leads.count) { _ in
                loadDataAndProcess()
            }
            .onChange(of: selectedItems) { _ in
                updateLeads()
            }

            /* .onReceive($leads) { leads in
                 let leads = leads//.prefix(20)

                 //let path = GMSMutablePath()

                 print("start")

                 for leadModel in leads {
                     if
                         //let latitudeStr = leadModel.latitude,
                         //let longitudeStr = leadModel.longitude,
                         let latitude = Double(leadModel.latitude),
                         let longitude = Double(leadModel.longitude) {

                         let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                         if path.contains(coordinate: coordinate, geodesic: false) {
                             //print(".....si esta dentro a....")
                             leadsInsidePath.append(leadModel)
                             selectedItems.insert(leadModel.status_id.name)
                             //selectedItems.insert(leadModel.status_id.name)
                         }else{
                             //leadsInsidePath.append(leadModel)
                             //print("NO esta afuera b.")
                         }
                     }
                 }
                 print("End", leadsInsidePath.count)

                 //leadsInsidePath = leads
                 groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
                     counts[lead.status_id.name, default: 0] += 1
                 }

                 updateLeads()
             }

              */
            .onTapGesture {
               // isModalPresented.toggle()
            }

            .sheet(isPresented: $isUserChange) {
                Text("User")
            }

            .sheet(isPresented: $isModalPresented) {
                VStack {
                    SuperIcon2(status: $sta)

                        .frame(width: 50, height: 50)
                    Text("Status: \(statusManager.lastStatus?.name ?? "")")
                }
                .confirmationDialog(
                    "Are you sure?",
                    isPresented: $statusConfirm,
                    actions: {
                        Button("Change", role: .destructive) {
                            print(99999)
                        }
                    }
                )
                .padding(10)
                Divider()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 75))], spacing: 8) {
                        ForEach(statusManager.statusList, id: \._id) { item in
                            VStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                                    .frame(width: 40, height: 40)
                                    .padding(5)
                                    .onTapGesture {
                                        statusManager.lastStatus = item
                                        statusManager.lastStatusType = getStatusType(from: item.name)
                                        sta = statusManager.lastStatusType ?? StatusType.demo
                                        // isModalPresented.toggle()
                                    }

                                Text(item.name)
                                    .frame(width: 50, height: 30)
                                // .foregroundColor(.blue)
                            }.padding(0)
                        }
                    }
                }

                HStack {
                    Button("back") {
                        isModalPresented.toggle()
                    }
                    Spacer()
                    Button("save") {
                        statusConfirm = true
                        // isModalPresented.toggle()
                    }
                }
                .padding(40)
            }
        }
    }

    func updateLeads() {
        filteredLeads = leadsInsidePath.filter { lead in
            selectedItems.contains(lead.status_id.name)
        }
    }

    func toggleSelection(_ statusName: String) {
        if selectedItems.contains(statusName) {
            selectedItems.remove(statusName)
        } else {
            selectedItems.insert(statusName)
        }

        updateLeads()
    }

    private func loadDataAndProcess() {
        // let first100Leads = leads.prefix(100)  // Filtra solo los primeros 100 registros
        print("begin calculations")

        var temp: [LeadModel] = []
        var tempSet: Set<String> = []
        for leadModel in leads {
            if
                // let latitudeStr = leadModel.latitude,
                // let longitudeStr = leadModel.longitude,
                let latitude = Double(leadModel.latitude),
                let longitude = Double(leadModel.longitude) {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                if path.contains(coordinate: coordinate, geodesic: false) {
                    // leadsInsidePath.append(leadModel)
                    temp.append(leadModel)
                    // selectedItems.insert(leadModel.status_id.name)
                    tempSet.insert(leadModel.status_id.name)
                    // selectedItems.insert(leadModel.status_id.name)
                }
            }
        }

        leadsInsidePath = temp
        selectedItems = tempSet

        print("end calculations")

        groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
            counts[lead.status_id.name, default: 0] += 1
        }

        // Imprimir los resultados
        /* for (statusName, count) in groupedLeads {
             print("Status: \(statusName), Count: \(count)")
         }
         */
        updateLeads()
    }
}

/*
 #Preview {
     HomeScreen(option:"b")
 }
 */
/*
 struct GeoPreview2: PreviewProvider {
     static var previews: some View {
         XX()
     }

     struct XX: View {
         @State private var mode: Bool = true
         @State var showSettings = true
         //@State var path = GMSMutablePath()
         @StateObject var aqua = AquaFeelModel()
         var body: some View {
             PathOptionView(path: $aqua.path)
         }
     }
 }
 */
/*
 #Preview("yannye") {
     PathOptionView().onTapGesture {
         print("x")
     }
 }
 */

#Preview {
    MainAppScreenHomeScreenPreview()
}
