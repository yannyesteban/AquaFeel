//
//  CreateLead.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/1/24.
//

import SwiftUI
import UIKit

class CreatorViewModel: ObservableObject {
    @Published var selectedCreator: CreatorModel?
    @Published var creators: [CreatorModel] = [] // Rellenar con tus datos
    @Published var searchText = ""
    @Published var shouldDismissSheet: Bool = false

    func showCreatorList() {
        selectedCreator = nil
        shouldDismissSheet = true
    }
}

struct TextWithIcon: View {
    let text: String

    var body: some View {
        HStack {
            SuperIconViewViewWrapper(status: getStatusType(from: "NHO"))
                .frame(width: 30, height: 30)
        }
    }
}

struct DatePickerString: View {
    var title: String
    @Binding var text: String

    private var realDate: Date {
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoDateFormatter.date(from: text) {
            return date
        } else {
            return Date()
        }
        
        
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: text) {
            return date
        } else {
            // If the conversion fails, returns the current date as the default value
            return Date()
        }
         */
    }

    var body: some View {
        DatePicker(
            title,
            selection: Binding<Date>(
                get: { self.realDate },
                set: { newValue in
                    // Convert the new selected date to a string format and assign to the ObservableLeadModel
                    /*let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                   // dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                    text = dateFormatter.string(from: newValue)
                     */
                    
                    let isoDateFormatter = ISO8601DateFormatter()
                    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    text = isoDateFormatter.string(from: newValue)
                }
            ),

            displayedComponents: [.date, .hourAndMinute]
        )
    }
}

struct MyStatus: View {
    @Binding var status: StatusId

    @State var sta: StatusType = .appt
    @State private var isModalPresented = false

    var statusList: [StatusId]
    var body: some View {
        HStack {
            VStack {
                SuperIcon2(status: $sta)

                    .frame(width: 50, height: 50)
                Text(status.name)
                    .frame(width: 50, height: 30)
            }.onTapGesture {
                isModalPresented.toggle()
            }
            .onAppear {
                sta = getStatusType(from: status.name)
            }
            .onChange(of: status.name) { newStatus in

                sta = getStatusType(from: newStatus)
            }

            ScrollView(.horizontal) {
                HStack {
                    ForEach(statusList, id: \._id) { item in

                        VStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: item.name))

                                .frame(width: 30, height: 30)
                                .padding(5)
                                .onTapGesture {
                                    status = item
                                }
                            Text(item.name)
                                .frame(width: 50, height: 30)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(5)

        }.padding(0)
            .sheet(isPresented: $isModalPresented) {
                VStack {
                    SuperIcon2(status: $sta)

                        .frame(width: 50, height: 50)
                    Text("Status: \(status.name)")
                }
                .padding(10)
                Divider()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(statusList, id: \._id) { item in
                            VStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                                    .onTapGesture {
                                        status = item
                                        isModalPresented.toggle()
                                    }

                                Text(item.name)
                                    .frame(width: 50, height: 30)
                                // .foregroundColor(.blue)
                            }.padding(0)
                        }
                    }
                }
                .padding(30)

                Button("back") {
                    isModalPresented.toggle()
                }
            }.padding(0)
    }
}

struct OwnerView: View {
    @State var text = ""
    @Binding var owner: CreatorModel
    @StateObject private var viewModel = CreatorViewModel()
    // @State var selectedCreator

    var body: some View {
        HStack {
            if owner._id == "" {
                Text(text)
                    .foregroundColor(.secondary.opacity(0.7))
            } else {
                Text("\(owner.firstName) \(owner.lastName)")
            }
        }

        // .frame(width: .infinity, height: .infinity)
        .onTapGesture {
            viewModel.showCreatorList()
        }
        .sheet(isPresented: $viewModel.shouldDismissSheet) {
            CreatorListView(selected: $owner, viewModel: viewModel)
        }.onReceive(viewModel.$selectedCreator) { _ in
        }
    }
}

struct CreatorListView: View {
    @Binding var selected: CreatorModel
    @ObservedObject var viewModel: CreatorViewModel
    @StateObject var user = UserManager()

    // @State var selected = false
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.creators.filter {
                    $0.firstName.localizedCaseInsensitiveContains(viewModel.searchText) ||
                        $0.lastName.localizedCaseInsensitiveContains(viewModel.searchText) || viewModel.searchText == ""
                }) { creator in

                    HStack {
                        Text("\(creator.firstName) \(creator.lastName)")

                            .onTapGesture {
                                viewModel.shouldDismissSheet = false
                                selected = creator
                            }
                        if creator._id == selected._id {
                            Image(systemName: creator._id == selected._id ? "checkmark.circle.fill" : "circle")
                            // .foregroundColor(.gray) // Consistent checkbox color
                        }
                    }
                    .foregroundColor(creator._id == selected._id ? .accentColor : .primary)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationBarTitle("Owners List", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                viewModel.shouldDismissSheet = false
            }) {
                Image(systemName: "xmark") // Use "xmark" or any other SF Symbol
            })
        }
        .onAppear {
            user.list()
        }
        .onReceive(user.$users) { users in
            viewModel.creators = users.map { user in
                CreatorModel(
                    _id: user._id, // Asegúrate de tener una propiedad que puedas utilizar como _id
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName
                )
            }
        }
    }
}

struct CreateLead: View {
    var profile:ProfileManager
    
    @State private var texto = ""
    @State private var date = Date()

    @Binding var lead: LeadModel

    @State var mode: Int = 2
    @ObservedObject var manager: LeadManager
    @Binding var updated: Bool
    
    @State private var deleteConfirm = false

    @State private var isShowingSnackbar = false

    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject private var viewModel = CreatorViewModel()

    @State var showErrorMessage = false
    @State var alertMessage = ""
    @EnvironmentObject var store: MainStore<UserData>
    //@State var userRole = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isAppointmentVisible = false
  
    //@State var userId: String
    var onSave: (Bool) -> Void

    @State var alertTitle = "Alert"
    //@State var alertMessage = "Error"
    private func loadDataAndProcess() {
        lead2.statusAll()
    }

    var body: some View {
        NavigationStack {
            if mode != 0 {
                Form {
                    Section {
                        TextField("First Name", text: $lead.first_name)
                        TextField("Last Name", text: $lead.last_name)

                        PhoneView("Phone Number", text: $lead.phone) {
                            lead.makePhoneCall()
                        }

                        PhoneView("Alternative Number", text: $lead.phone2) {
                            lead.makePhoneCall(lead.phone2)
                        }

                        TextField("Email", text: $lead.email)

                    } header: {
                        HStack {
                            Text("Contact Info")
                            if mode == 1 {
                                Text("*")
                            }
                        }
                    }

                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    Section("Address") {
                        /* AddressView<LeadModel>(label: "write a address", leadAddress: $lead) */
                        AddressField<LeadModel>(label: "Start Point", leadAddress: $lead)
                        TextField("Apt / Suite", text: $lead.apt)
                        TextField("City", text: $lead.city)
                        TextField("State", text: $lead.state)
                        HStack {
                            TextField("Zip Code", text: $lead.zip)
                            TextField("Country", text: $lead.country)
                        }
                        
                    }

                    Section("Status") {
                        HStack {
                            MyStatus(status: $lead.status_id, statusList: lead2.statusList)
                        }
                    }
                    .alert(isPresented: $showErrorMessage) {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    Section("Appointment / Callback time") {
                        Button(action: {
                            withAnimation {
                                if lead.appointment_date != "" {
                                    // Si ya hay una cita programada, cancela la cita
                                    lead.appointment_date = ""
                                } else {
                                    // De lo contrario, muestra el selector de fecha
                                    isAppointmentVisible.toggle()
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: lead.appointment_date != "" ? "trash" : "calendar")
                                Text(lead.appointment_date != "" ? "Cancel Appointment" : "Set Appointment")
                            }
                            .foregroundColor(lead.appointment_date != "" ? .red : .primary) // Cambiar el color del icono
                        }
                        
                        if isAppointmentVisible || lead.appointment_date != "" {
                            
                                DatePickerString(title: "Date", text: $lead.appointment_date)
                                    .onChange(of: lead.appointment_date){ newDate in
                                        lead.appointment_time = newDate
                                    }
                            Text("Old Time \(formattedTime(from : lead.appointment_time))")
                        }
                        
                    }
                    
                   
                    

                    if mode == 2 {
                        if profile.role == "ADMIN" || profile.role == "MANAGER" {
                            Section {
                                OwnerView(text: "Select User", owner: $lead.created_by)
                            } header: {
                                Text("Owner")
                            }
                        } else {
                            Section {
                                Text("\(lead.created_by.firstName) \(lead.created_by.lastName)")
                            } header: {
                                Text("Owner")
                            }
                        }
                    }

                    Section("Note") {
                        TextField("", text: $lead.note, axis: .vertical)
                            .lineLimit(2 ... 4)
                    }
                    

                    if mode == 2 {
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
                }
                
                .onChange(of: mode) { newMode in
                    if newMode == 1 {
                        
                        lead = LeadModel()
                        lead.created_by = CreatorModel(_id: profile.userId)
                        lead.user_id = profile.userId
                    }
                }
                .background(.blue)
                .navigationTitle("Lead")
                
                
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if isShowingSnackbar {
                            ProgressView("")

                        } else {
                            
                            
                            
                            Button {
                                lead.makePhoneCall()
                            } label: {
                                Label("", systemImage: "phone")
                                    .font(.title3)//arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                           
                            Button {
                                lead.sendSMS()
                            } label: {
                                Label("", systemImage: "message")
                                    .font(.title3)//arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                            Button {
                                lead.openGoogleMaps()
                            } label: {
                                Label("", systemImage: "globe")
                                    .font(.title3)//
                            }
                            Button {
                                alertMessage = lead.validForm()

                                if alertMessage != "" {
                                    showErrorMessage = true

                                    return
                                } else {
                                    isShowingSnackbar = true
                                }

                                var saveMode = ModeSave.edit
                                if mode == 1 {
                                    saveMode = .add
                                }
                                var result = false
                                manager.save(body: lead, mode: saveMode) { ok, newLead in

                                    isShowingSnackbar = false

                                    print("showSaveOk: A", ok)
                                    if ok, let newLead = newLead {
                                        
                                        showErrorMessage = true
                                        alertMessage = "record was saved correctly!"
                                        
                                        updated = true
                                        lead.id = newLead.id
                                        mode = 2

                                        if saveMode == .add {
                                            manager.leads.insert(lead, at: 0)
                                            result = true
                                        }
                                    } else {
                                        showErrorMessage = true
                                        alertMessage = "Error: record wasn't saved!"
                                    }

                                    onSave(result)
                                }

                            } label: {
                                Label("Save", systemImage: "externaldrive.fill")
                                    .font(.title3)
                            }
                        }
                        
                    }
                }
                /*if mode == 2 {
                    HStack {
                        if !lead.phone.isEmpty {
                            Button {
                                lead.makePhoneCall()
                            } label: {
                                HStack {
                                    Image(systemName: "phone")
                                        .imageScale(.large)
                                }
                            }
                            .padding(.horizontal, 30)

                            Button {
                                lead.sendSMS()
                            } label: {
                                HStack {
                                    Image(systemName: "message")
                                        .imageScale(.large)
                                }
                            }
                            .padding(.horizontal, 30)
                        }

                        Button {
                            lead.openGoogleMaps()

                        } label: {
                            HStack {
                                Image(systemName: "arrow.turn.up.right")
                                    .imageScale(.large)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }*/

            } else {
                
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            SuperIcon2(status: Binding(
                                get: { getStatusType(from: lead.status_id.name) },
                                set: { _ in
                                }
                            ))
                            .frame(width: 34, height: 34)
                            Text(lead.status_id.name)
                                .font(.caption2)
                                .foregroundColor(Color.primary)
                        }

                        VStack(alignment: .leading) {
                            Text("\(lead.first_name) \(lead.last_name)")

                            Text("\(lead.street_address)")
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    Form {
                        Section("Status") {
                            HStack {
                                MyStatus(status: $lead.status_id, statusList: lead2.statusList)
                            }

                        }.padding(0)

                        Section("Note") {
                            TextField("", text: $lead.note, axis: .vertical)
                                .lineLimit(2 ... 4)

                        }.padding(0)
                    }
                    

                }.padding(0)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                mode = 2

                            } label: {
                                Text("Edit")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            
                            Button {
                                lead.makePhoneCall()
                            } label: {
                                Label("", systemImage: "phone")
                                    .font(.title3)//arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                            
                            Button {
                                lead.sendSMS()
                            } label: {
                                Label("", systemImage: "message")
                                    .font(.title3)//arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                            Button {
                                lead.openGoogleMaps()
                            } label: {
                                Label("", systemImage: "globe")
                                    .font(.title3)//
                            }
                            
                            if isShowingSnackbar {
                                ProgressView("")

                            } else {
                                Button {
                                    isShowingSnackbar = true
                                    var saveMode = ModeSave.edit
                                    if mode == 1 {
                                        saveMode = .add
                                    }
                                    manager.save(body: lead, mode: saveMode) { _, _ in

                                        isShowingSnackbar = false
                                    }
                                    onSave(false)

                                } label: {
                                    Label("Save", systemImage: "externaldrive.fill")
                                        .font(.title3)
                                }
                            }
                        }
                    }
            }
        }

        
        .onAppear {
            loadDataAndProcess()

            
            if mode == 1 {
                print("--- - - - -- - ******** * * * * * * ***")
                lead = LeadModel()
                lead.created_by = CreatorModel(_id: profile.userId, firstName: profile.info.firstName, lastName: profile.info.lastName)
                lead.owned_by = manager.userId
                print("new: ", manager.userId)
                //lead.created_by = CreatorModel(_id: manager.user)
            }
        }
        
        .alert(isPresented: $deleteConfirm) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete the lead?"),
                primaryButton: .destructive(Text("Delete")) {
                    let leadQuery = LeadQuery()
                        .add(.id, lead.id)
                    manager.delete(query: leadQuery, leadId: lead.id) { result in
                        
                        if result {
                            presentationMode.wrappedValue.dismiss()
                            updated = true
                        } else {
                            print("after delete, fail ", result)
                            showErrorMessage = true
                            alertMessage = "Failure, the operation was not completed."
                        }
                       
                    }
                },
                secondaryButton: .cancel()
            )
        }
        /*
        .confirmationDialog(
            "Delete record",
            isPresented: $deleteConfirm,
            actions: {
                Button("Delete", role: .destructive) {
                    let leadQuery = LeadQuery()
                        .add(.id, lead.id)
                    manager.delete(query: leadQuery, leadId: lead.id) { result in
                       
                        if result {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showErrorMessage = true
                            errorMessage = "Failure, the operation was not completed."
                        }
                        print("after delete", result)
                        
                        //self.mode = 1
                        //self.lead = LeadModel()
                    }
                }
            },
            message: {
                Text("are you sure to delete record?")
            }
        )
         */
    }
}

struct TestCreateLead: View {
    @StateObject var manager = LeadManager()
    @StateObject var user = UserManager()
    @State var nombrecito = "Juancito"
    @State private var store = MainStore<UserData>() // AppStore()
    @State private var updated = false
    @State var lead: LeadModel = LeadModel(
        id: "65c56f5ff4a97859d1955f89",
        business_name: "N/A",
        first_name: "Nuñez",
        last_name: "Yanny E",
        phone: "",
        phone2: "",
        email: "",

        street_address: "4220 Evergreen Drive, Woodbridge, Virginia, EE. UU.",
        apt: "",
        city: "Prince William County",
        state: "VA",
        zip: "22193",
        country: "Estados Unidos",
        longitude: "-77.3374901",
        latitude: "38.637312",

        appointment_date: "2024-02-01T05:45:00.000Z",
        appointment_time: "2024-02-08T22:00:27.000Z",
        status_id: StatusId()
    )
    var body: some View {
        CreateLead(profile: ProfileManager(), lead: $lead, mode: 2,manager: manager, updated: $updated) { result in
            print(result)
        }
        .onAppear {
            // manager.mode = 2
            manager.get(id: "65a9b6b8f4a97859d1928415" /* "65dd296bf4a97859d198204d" */ )
        }
        .onReceive(manager.$selected, perform: { x in

            lead = x ?? LeadModel()
        })
        .environmentObject(store)
    }
}

#Preview {
    TestCreateLead()
}

#Preview("list") {
    LeadListHomeScreenPreview()
}
