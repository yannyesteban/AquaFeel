//
//  RouteListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/3/24.
//

import SwiftUI
enum RecordMode {
    case none
    case read
    case new
    case edit
    case delete
}

class AddressManager: ObservableObject {
    @Published var address = AddressModel()
}

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
                            // print("...", x?.formatted_address ?? "")
                            // prettyPrint(x)
                            if let x = x {
                                addressManager.address = placeViewModel.decodeDetails(placeDetails: x)
                                print(addressManager.address)

                                /*
                                 var leadAddress:AddressModel = placeViewModel.decodeDetails(placeDetails: x) as! AddressModel

                                 print(leadAddress?.city)
                                 */
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

struct AddressRoute<T: AddressProtocol>: View {
    public var label: String

    @Binding var address: String
    @Binding var latitude: String
    @Binding var longitude: String

    @State private var searchText = ""
    @State private var searchText2 = ""
    @State private var isModalPresented = false
    @State var value = 0
    //@Binding var leadAddress: T

    @StateObject private var location = PlaceManager()
    @StateObject private var placeViewModel = PlaceViewModel()
    @State private var locationWaiting = false

    //@State var address = AddressModel()

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
                print(new.street_address)
                address = new.street_address
                latitude = new.latitude
                longitude = new.longitude
            }
            

        }
        
        .onReceive(location.$location) { newValue in
            print("one")

            if let place = newValue {
                latitude = String(place.latitude)
                longitude = String(place.longitude)
                print("two", latitude, longitude)
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

struct LeadPicker: View {
    var profile:ProfileManager
    
    @State private var isCreateLeadActive = false
    @State var filter = ""

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager()
    // @StateObject var user = UserManager()

    @State private var isFilterModalPresented = false

    @State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()

    @Binding var selectedLeads: [LeadModel]
    // @State var selectedLeads: Set<LeadModel> = []

    // @EnvironmentObject var store: MainStore<UserData>
    func toggleLeadSelection(_ lead: LeadModel) {
        if let index = selectedLeads.firstIndex(of: lead) {
            selectedLeads.remove(at: index) // Si ya está seleccionado, lo eliminamos
        } else {
            selectedLeads.append(lead) // Si no está seleccionado, lo añadimos
        }
    }

    func loadMoreContent() {
        if !isLoading {
            isLoading = true
            // This simulates an asynchronus call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let moreNumbers = numbers.count + 1 ... numbers.count + 20
                numbers.append(contentsOf: moreNumbers)
                isLoading = false
                if numbers.count > 250 {
                    isFinished = true
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    HStack {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                // .fontWeight(.semibold)
                                // .foregroundStyle(.blue)

                                Text("\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                            }
                            Spacer()

                            // Agregar el icono SF Symbol para indicar la selección
                            Image(systemName: selectedLeads.contains(manager.leads[index]) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedLeads.contains(manager.leads[index]) ? .blue : .gray)
                                .onTapGesture {
                                    // Cambiar el estado de selección del lead cuando se hace tap
                                    toggleLeadSelection(manager.leads[index])
                                }
                        }
                    }

                }.onAppear {
                    print("list count is", manager.leads.count)
                }

                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .foregroundColor(.red)
                    .onAppear {
                        manager.list()
                    }
            }

            /* List($lead.leads.indices, id: \.self) { index in

             NavigationLink(destination:  CreateLead(lead: $lead.leads[index], manager: lead2){}) {
             HStack{
             SuperIconViewViewWrapper(status: getStatusType(from: lead.leads[index].status_id.name))
             .frame(width: 34, height: 34)
             VStack(alignment: .leading) {

             Text("\(lead.leads[index].first_name) \(lead.leads[index].last_name)" )
             //.fontWeight(.semibold)
             //.foregroundStyle(.blue)

             Text( "\(lead.leads[index].street_address)")
             .foregroundStyle(.gray)

             }

             }

             }

             } */

            .onAppear {
                print("onAppear...")
                manager.userId = profile.userId
                manager.role = profile.role
                manager.token = profile.token

                manager.initFilter(completion: { _, _ in

                })
                // let leadQuery = LeadQuery()
                // .add(.limit , "10")
                // .add(.searchKey, "all")
                // .add(.searchValue, "yanny")

                // lead.load(count: 3)
                // print(9999)
                // user.list(){}
            }

            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        manager.reset()
                        manager.load(count: 9)

                    } label: {
                        HStack {
                            // Text("Reset")
                            Image(systemName: "gobackward")
                        }
                        // .font(.caption)
                        // .fontWeight(.bold)
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Leads List")

            HStack {
                VStack {
                    Divider()
                        .padding(.horizontal, 20)
                        /*
                        .toolbar {
                            ToolbarItem(placement: .automatic) {
                                // ToolbarItemGroup(placement: .automatic){

                                NavigationLink {
                                    CreateLead(lead: $lead, mode: 1, manager: manager, userId: userId) { _ in
                                    }

                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                         */
                    // .toolbarBackground(.hidden, for: .navigationBar)

                    TextField("search by...", text: $manager.filter.textFilter)
                        .onChange(of: manager.filter.textFilter, perform: { newSearchText in

                            // lead.textFilter = "pedro alejandro"
                            searchTimer?.invalidate()

                            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                                let leadQuery = LeadQuery()
                                    .add(.limit , "30")
                                    .add(.searchKey, "all")
                                    .add(.offset, "0")
                                    .add(.limit, "40")
                                    .add(.searchValue, newSearchText)
                                //lead2.loadAll(query:leadQuery)
                                print("search() 1.0")
                                manager.search()
                            }

                        })
                        .padding(.bottom, 5).padding(.horizontal, 20)
                    Divider()
                        .padding(.bottom, 10)
                        .padding(.horizontal, 20)
                }

                Button(action: {
                    // Acción para mostrar la ventana modal con filtros
                    isFilterModalPresented.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                .padding()
            }
            // HStack{
            /* Divider()
             .padding(.horizontal, 20)

             //.overlay(VStack{Divider().offset(x: 0, y: 15)})
             Divider()
             .padding(.bottom, 10)
             .padding(.horizontal, 20)
             */

            // }

        }.sheet(isPresented: $isFilterModalPresented) {
            FilterOption(filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                print("reseteando")
                manager.reset()
            }
            .onAppear {
                // lead2.statusAll()
            }

            Button(action: {
                // Acción para mostrar la ventana modal con filtros
                isFilterModalPresented.toggle()
            }) {
                Text("Close")
                /* Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                 .foregroundColor(.blue)
                 .font(.system(size: 20)) */
            }
            .padding()
        }

        .onAppear {
            // print(":::::::", store.token)
            // manager.user = store.id
            // manager.token = store.token
            // manager.role = store.role

            manager.user = profile.userId
            manager.token = profile.token
            manager.role = profile.role

        }
    }
}

// Struct to display a local date
struct DateLocalView: View {
    // The original date string
    let dateString: String

    // The formatted date
    var formattedDate: String {
        // Create a date formatter
        let dateFormatter = DateFormatter()

        // Set the format of the original string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        // Configure the time zone, if necessary
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        // Convert the string to a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Create a local date and time formatter
            let localDateFormatter = DateFormatter()

            // Configure the date and time style according to your preferences
            localDateFormatter.dateStyle = .medium
            localDateFormatter.timeStyle = .medium

            // Convert the date to a string in local format
            return localDateFormatter.string(from: date)

        } else {
            // If the date could not be converted, return an error message
            return "Failed to convert string to Date"
        }
    }

    // The body of the view
    var body: some View {
        // Display the formatted date
        Text(formattedDate)
    }
}

struct RouteView: View {
    var profile:ProfileManager
    @ObservedObject var routeManager:RouteManager
    
    
    @State var mode: RecordMode = .none
    @State var id: String
    @State var AddressFrom: LeadModel = LeadModel()
    @State var AddressTo: LeadModel = LeadModel()

    @State var name: String = ""

    @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    @State var leads: [LeadModel] = []
    

    @State var isShowingSnackbar = false
    @State var showPicker = false
    @State var deleteConfirm = false
    
    @State var ok = false
    @State var error = false
    @State var message = ""
    @State var completed = false
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

                /* List {
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
                 } */

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
            if mode == .edit {
                Section {
                    Button(action: {
                        deleteConfirm = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            /*
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
             */
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

                Button("Route It") {
                    //showPicker = true
                }
                NavigationLink {
                    LeadPicker(profile: profile, selectedLeads: $routeManager.route.leads)

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            Task {
                print("mode", mode)
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
            
            
            Button{
                showPicker = true
            }label: {
                Label("Add Leads", systemImage: "person.badge.plus")
                    .font(.title3)
            }
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
            }
        }
        .alert("Account Created Successfully", isPresented: $ok) {
            Button("Ok") {
                completed = true
                //print(completed)
                // print(store.userData.auth)
            }
        } message: {
            Text("Password updated sucessfully")
        }
        .confirmationDialog(
            "Delete record",
            isPresented: $deleteConfirm,
            actions: {
                Button("Delete", role: .destructive) {
                    Task{
                        
                        
                        if let result = try? await routeManager.delete(routeId: id){
                            
                            try? await routeManager.list()
                            
                            if result.statusCode == 201 {
                                message = result.message
                                ok = true
                                //mode = .new
                                routeManager.setNew(leads : [])
                                DispatchQueue.main.async {
                                    mode = .new
                                    /*
                                    id = "0"
                                    leads = []
                                    print("deleteeeeee")
                                    routeManager.route = RouteModel()
                                     */
                                }
                                
                                
                            } else{
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

struct RouteListView: View {
    var profile:ProfileManager
    @StateObject var routeManager = RouteManager()
    var body: some View {
        NavigationStack {
            List {
                ForEach(routeManager.routes, id: \._id) { route in
                    NavigationLink {
                        RouteView(profile: profile, routeManager: routeManager, mode: .edit, id: route._id, leads: route.leads)
                    } label: {
                        HStack {
                            Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath")
                            VStack(alignment: .leading) {
                                Text(route.name)

                                DateLocalView(dateString: route.createdOn)
                                Text("Stop: \(route.leads.count)")
                            }
                        }
                    }
                }
            }
            // .navigationTitle("Create Lead")
            .navigationBarTitle("Route List")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    // ToolbarItemGroup(placement: .automatic){

                    NavigationLink {
                        RouteView(profile: profile, routeManager: routeManager , mode: .new, id: "0", leads: [])

                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear{
                print("********* ----- ---- ", profile.userId)
                routeManager.userId = profile.userId
                
                Task {
                    do {
                        //try await detail(routeId: "64c82646b6b8eb6360a05382" )
                        try await routeManager.list()
                    } catch {
                        print(error)
                    }
                    
                    
                }
                
            }
        }
    }
}

#Preview {
    RouteListView(profile:  ProfileManager())
}
