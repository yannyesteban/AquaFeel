//
//  CreateLead.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/1/24.
//

import SwiftUI
import UIKit

struct CreateLead: View {
    var profile: ProfileManager

    @State private var texto = ""
    @State private var date = Date()

    @Binding var lead: LeadModel

    @State var mode: Int = 2
    @ObservedObject var manager: LeadManager
    @Binding var updated: Bool

    @State private var deleteConfirm = false

    @State private var isWaiting = false

    // @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    @StateObject private var statusManager = StatusManager()

    @StateObject private var viewModel = CreatorManager()
    @StateObject var adminManager = AdminManager()

    @State var showErrorMessage = false
    @State var showErrorMessage2 = false
    @State var alertMessage = ""
    @EnvironmentObject var store: MainStore<UserData>
    // @State var userRole = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isAppointmentVisible = false

    @State private var showHistory = false
    // @State var userId: String
    var onSave: (Bool) -> Void

    @State var alertTitle = "Message"

    @State var showAlert = false

    @State private var alert: Alert!
    @State var order: OrderModel = OrderModel()
    @State var credit: CreditModel = CreditModel()
    @State var creditCard: CreditCardModel = CreditCardModel()
    // @State var alertMessage = "Error"
    private func loadDataAndProcess() {
        statusManager.statusAll()
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
                            if lead.pending {
                                Text("(Pending)")
                            }
                        }
                    }

                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    Section("Address") {
                        /* AddressView<LeadModel>(label: "write a address", leadAddress: $lead) */
                        AddressField<LeadModel>(label: "Address", leadAddress: $lead, withPlaceButton: mode == 1)
                        TextField("Street", text: $lead.street_address).disabled(true)
                        if lead.apt != ""{
                            TextField("Apt / Suite", text: $lead.apt).disabled(true)
                        }
                       
                        TextField("City", text: $lead.city).disabled(true)
                        TextField("State", text: $lead.state).disabled(true)
                        HStack {
                            TextField("Zip Code", text: $lead.zip).disabled(true)
                            TextField("Country", text: $lead.country).disabled(true)
                        }.disabled(true)
                        /*
                        //if lead.street_address != "" {
                            Text(lead.street_address)
                            if lead.apt != ""{
                                TextField("Apt / Suite", text: $lead.apt)
                            }
                            
                            Text(lead.city)
                            Text(lead.state)
                            HStack {
                                Text(lead.zip)
                                Spacer()
                                Text(lead.country)
                            }
                        //}
                         */
                         
                    }

                    Section("Status") {
                        HStack {
                            LeadStatusView(status: $lead.status_id, statusList: statusManager.statusList)
                        }
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
                                Text(lead.appointment_date != "" ? "Cancel Appointment" : "Set Appointment")
                                Spacer()
                                Image(systemName: lead.appointment_date != "" ? "trash" : "calendar")
                            }
                            .foregroundColor(lead.appointment_date != "" ? .red : .primary) // Cambiar el color del icono
                        }

                        if isAppointmentVisible || lead.appointment_date != "" {
                            DatePickerString(title: "Date", text: $lead.appointment_date)
                                .onChange(of: lead.appointment_date) { newDate in
                                    lead.appointment_time = newDate
                                }

                            if lead.appointment_time != lead.appointment_date {
                                Text("Old Time \(formattedTime(from: lead.appointment_time))")
                            }
                        }
                    }

                    Section("Note") {
                        TextField("Write a note...", text: $lead.note, axis: .vertical)
                            .lineLimit(2 ... 4)
                         HStack {
                             Text("Add to favorites")
                             Spacer()
                             Button(action: {
                                 lead.favorite.toggle()
                             }) {
                                 Image(systemName: lead.favorite ? "heart.fill" : "heart")
                                     .font(.system(size: 20, weight: .light))
                                     .foregroundColor(lead.favorite ? .red : .gray)
                             }
                         }
                    }

                    /*
                     if mode == 2 && (profile.role == "ADMIN" || profile.role == "MANAGER") {
                         Section {
                             OwnerView(text: "Select User", owner: $lead.created_by, adminManager: adminManager)
                         } header: {
                             Text("Owner")
                         }
                     }*/

                    if mode == 2 {
                        Section {
                            if profile.role == "ADMIN" || profile.role == "MANAGER" {
                                OwnerView(text: "Select User", owner: $lead.created_by, adminManager: adminManager)
                            }
                            HStack {
                                Text("Created On:")
                                Spacer()
                                Text("\(lead.createdOn.formatted())")
                            }
                            HStack {
                                Text("Updated On:")
                                Spacer()
                                Text("\(lead.updatedOn.formatted())")
                            }

                        } header: {
                            Text(profile.role == "ADMIN" || profile.role == "MANAGER" ? "Owner" : "")
                        }

                        Section {
                            Button(action: {
                                showHistory.toggle()
                            }) {
                                HStack {
                                    Text("Show History")
                                    Spacer()
                                    Image(systemName: "clock.arrow.circlepath")
                                }
                            }
                        }

                        Section {
                            
                            NavigationLink {
                                LeadResourceEditList(profile: profile, leadId: lead.id)
                            } label: {
                                Label("Resources", systemImage:  "doc.richtext.fill")
                            }
                           
                            
                            NavigationLink {
                                LeadWorkOrder(profile: profile, lead: lead, order: $order)
                            } label: {
                                Label("Work Order", systemImage: "scroll.fill")
                            }

                            NavigationLink {
                                LeadCredit(profile: profile, lead: lead, credit: $credit)
                            } label: {
                                  
                                if #available(iOS 17.0, *) {
                                    Label("Credit Application", systemImage: "creditcard.trianglebadge.exclamationmark.fill")
                                } else {
                                    Label("Credit Application", systemImage: "creditcard")
                                }
                            }

                            NavigationLink {
                                LeadCreditCard(profile: profile, lead: lead, creditCard: $creditCard)
                            } label: {
                                Label("Credit Card Authorization", systemImage: "creditcard.fill")
                            }

                            
                        }
                        
                        
                        Section {
                            Button(action: {
                                doDelete()

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
                        if isWaiting {
                            ProgressView("")

                        } else {
                            Button {
                                lead.makePhoneCall()
                            } label: {
                                Label("", systemImage: "phone.fill")
                                    .font(.title3) // arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)

                            Button {
                                lead.sendSMS()
                            } label: {
                                Label("", systemImage: "message.fill")
                                    .font(.title3) // arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                            Button {
                                if profile.mapApi == .appleMaps {
                                    lead.openAppleMaps()
                                } else {
                                    lead.openGoogleMaps()
                                }

                            } label: {
                                Label("", systemImage: "location.fill")
                                    .font(.title3) //
                            }
                            Button {
                                doSave()

                            } label: {
                                Label("Save", systemImage: "externaldrive.fill")
                                    .font(.title3)
                            }
                        }
                    }
                }

            } else {
                if showErrorMessage2 {
                    Label(alertMessage, systemImage: "info.bubble.fill")
                        .padding(2)
                        .foregroundColor(Color.accentColor)
                        // .foregroundColor(.white)
                        // .cornerRadius(2)
                        .labelStyle(.titleAndIcon)
                        // .labelStyle(.iconOnly)

                        // .imageScale(.large)

                        .opacity(showErrorMessage2 ? 1 : 0)
                        // .rotationEffect(.degrees(showMessage ? 90 : 0))

                        .scaleEffect(showErrorMessage2 ? 1 : 0)
                        .font(.callout)

                        // .frame(height: effect ? .infinity : 0)
                        .padding()
                }
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
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
                                LeadStatusView(status: $lead.status_id, statusList: statusManager.statusList)
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
                                Label("", systemImage: "phone.fill")
                                    .font(.title3) // arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)

                            Button {
                                lead.sendSMS()
                            } label: {
                                Label("", systemImage: "message.fill")
                                    .font(.title3) // arrow.turn.up.right
                            }
                            .disabled(lead.phone.isEmpty)
                            Button {
                                if profile.mapApi == .appleMaps {
                                    lead.openAppleMaps()
                                } else {
                                    lead.openGoogleMaps()
                                }
                                
                            } label: {
                                Label("", systemImage: "location.fill")
                                    .font(.title3) //
                            }

                            if isWaiting {
                                ProgressView("")

                            } else {
                                Button {
                                    isWaiting = true
                                    var saveMode = ModeSave.edit
                                    if mode == 1 {
                                        saveMode = .add
                                    } /*
                                     manager.save(body: lead, mode: saveMode) { _, _ in

                                         isShowingSnackbar = false
                                     }
                                     onSave(false)
                                       */
                                    var result = false
                                    manager.save(body: lead, mode: saveMode) { ok, newLead in

                                        isWaiting = false

                                       
                                        if ok, let newLead = newLead {
                                            startMessage()
                                            alertMessage = "record was saved correctly!"

                                            updated = true
                                            lead.id = newLead.id
                                            // mode = 2

                                            if saveMode == .add {
                                                manager.leads.insert(lead, at: 0)
                                                result = true
                                            }
                                            DispatchQueue.main.async {
                                                lead.pending = false
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                lead.pending = true
                                            }
                                            startMessage()
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
            }
        }

        .sheet(isPresented: $showHistory) {
            NavigationStack {
                LeadHistoryView(id: lead.id)
                    .navigationBarTitle("History")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showHistory.toggle()
                            }) {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
            }
        }
        .onAppear {
            loadDataAndProcess()

            adminManager.token = profile.token
            adminManager.userId = profile.userId
            adminManager.role = profile.role

            if mode == 1 {
                lead = LeadModel()
                lead.created_by = CreatorModel(_id: profile.userId, firstName: profile.info.firstName, lastName: profile.info.lastName)
                lead.owned_by = manager.userId

                // lead.created_by = CreatorModel(_id: manager.user)
            }
        }

        .alert(isPresented: $showAlert) {
            alert
        }
    }

    private func setAlert(title: String, message: String) {
        alert = Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        showAlert = true
    }

    private func doSave() {
        alertMessage = lead.validForm()

        if alertMessage != "" {
            setAlert(title: "Message", message: alertMessage)
            // showErrorMessage = true

            return
        } else {
            isWaiting = true
        }

        var saveMode = ModeSave.edit
        if mode == 1 {
            saveMode = .add
        }
        var result = false
        manager.save(body: lead, mode: saveMode) { ok, newLead in

            isWaiting = false

        
            if ok, let newLead = newLead {
                // showErrorMessage = true
                // alertMessage = "record was saved correctly!"
                setAlert(title: "Message", message: "record was saved correctly!")
                updated = true
                lead.id = newLead.id
                mode = 2

                if saveMode == .add {
                    manager.leads.insert(lead, at: 0)
                    result = true
                }
                DispatchQueue.main.async {
                    lead.pending = false
                }
                // manager2.search()

            } else {
                DispatchQueue.main.async {
                    lead.pending = true
                }

                // showErrorMessage = true
                // alertMessage = "Error: record wasn't saved!"
                setAlert(title: "Message", message: "Error: record wasn't saved!")
            }

            onSave(result)
        }
    }

    private func doDelete() {
        // deleteConfirm = true
        showAlert = true
        alert = Alert(
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
                        setAlert(title: "Error", message: "Failure, the operation was not completed.")
                    }
                }
            },
            secondaryButton: .cancel()
        )
    }

    private func startMessage() {
        showErrorMessage2 = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showErrorMessage2 = false
        }
    }
}

struct TestCreateLead: View {
    @StateObject var manager = LeadManager()

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
        CreateLead(profile: ProfileManager(), lead: $lead, mode: 2, manager: manager, updated: $updated) { result in
            
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
