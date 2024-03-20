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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: text) {
            return date
        } else {
            // If the conversion fails, returns the current date as the default value
            return Date()
        }
    }

    var body: some View {
        DatePicker(
            title,
            selection: Binding<Date>(
                get: { self.realDate },
                set: { newValue in
                    // Convert the new selected date to a string format and assign to the ObservableLeadModel
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                    text = dateFormatter.string(from: newValue)
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
    @State var deleteConfirm = false

    @State private var isShowingSnackbar = false

    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject private var viewModel = CreatorViewModel()

    @State var showErrorMessage = false
    @State var errorMessage = ""
    @EnvironmentObject var store: MainStore<UserData>
    //@State var userRole = ""
    
    @State var userId: String
    var onSave: (Bool) -> Void

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

                    Section("Appointment / Callback time") {
                        DatePickerString(title: "Date", text: $lead.appointment_date)
                        DatePickerString(title: "Time", text: $lead.appointment_time)
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
                .alert(isPresented: $showErrorMessage) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .onChange(of: mode) { newMode in
                    if newMode == 1 {
                        lead = LeadModel()
                    }
                }
                .background(.blue)
                .navigationTitle("Lead Screen")

                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if isShowingSnackbar {
                            ProgressView("")

                        } else {
                            Button {
                                errorMessage = lead.validForm()

                                if errorMessage != "" {
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

                                    if ok, let newLead = newLead {
                                        lead.id = newLead.id
                                        mode = 2

                                        if saveMode == .add {
                                            result = true
                                        }
                                    }

                                    onSave(result)
                                }

                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                                    .font(.title3)
                            }
                        }
                    }
                }
                if mode == 2 {
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
                }

            } else {
                VStack {
                    HStack {
                        VStack {
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
                    }
                    .padding(6)
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
                                    Label("Save", systemImage: "square.and.arrow.down")
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
                lead = LeadModel()
                lead.user_id = userId
                lead.owned_by = manager.user
                print("new: ", manager.user)
                lead.created_by = CreatorModel(_id: manager.user)
            }
        }

        .confirmationDialog(
            "Delete record",
            isPresented: $deleteConfirm,
            actions: {
                Button("Delete", role: .destructive) {
                    let leadQuery = LeadQuery()
                        .add(.id, lead.id)
                    manager.delete(query: leadQuery) { result in
                        print("after delete", result)
                        self.mode = 1
                        self.lead = LeadModel()
                    }
                }
            },
            message: {
                Text("are you sure to delete record?")
            }
        )
    }
}

struct TestCreateLead: View {
    @StateObject var manager = LeadManager()
    @StateObject var user = UserManager()
    @State var nombrecito = "Juancito"
    @State private var store = MainStore<UserData>() // AppStore()
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
        CreateLead(profile: ProfileManager(), lead: $lead, mode: 2,manager: manager, userId: "") { result in
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
