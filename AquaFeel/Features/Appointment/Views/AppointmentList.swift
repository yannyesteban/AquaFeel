//
//  AppointmentList.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/3/24.
//

import SwiftUI

enum LeadModeFilter {
    case all
    case today
    case last30
}

func formattedTime(from text: String) -> String {
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = isoDateFormatter.date(from: text) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    } else {
        return "-"
    }
}

struct AppointmentList: View {
    var profile: ProfileManager
    @Binding var updated: Bool

    @State private var isCreateLeadActive = false
    @State var filter = ""

    @StateObject var manager: AppointmentManager = AppointmentManager(filterMode: .all)
    // @StateObject var user = UserManager()

    @State private var isFilterModalPresented = false

    @State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()
    @State var showLeads = false
    @State var filterMode: LeadModeFilter = .all
    @State var userId: String // = "DD2EMns3y"
    // @EnvironmentObject var store: MainStore<UserData>
    @State private var store = MainStore<UserData>() // AppStore()
    @StateObject var leadManager = LeadManager()


    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    NavigationLink(destination:

                        CreateLead(profile: profile, lead: $manager.leads[index], mode: 2, manager: leadManager, updated: $updated) { _ in }
                    ) {
                        HStack {
                            VStack(alignment: .center) {
                                SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                    .frame(width: 34, height: 34)
                                Text(formattedTime(from: manager.leads[index].appointment_time)).font(.footnote)
                            }.frame(width: 60)

                            VStack(alignment: .leading) {
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                    .font(.subheadline)

                                Text("\(manager.leads[index].street_address)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(0)
                if isLoading { 
                    
                    ProgressView( )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .foregroundColor(.red)
                       
                } else {
                    if manager.leads.count == 0 {
                        Text("No leads found!")
                    }
                }
                
               
            }

            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        // manager.reset()
                        // manager.load(count: 9)

                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                        }

                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("My Appointments")
        }

        .task {
            isLoading = true
            manager.showLeads = showLeads
            manager.filterMode = filterMode
            manager.userId = userId

            try? await manager.list()
            isLoading = false
        }
        .environmentObject(store)
    }
}

#Preview {
    AppointmentList(profile: ProfileManager(), updated: .constant(false), filterMode: .all, userId: "DD2EMns3y") // DD2EMns3y"
}
