//
//  AdminScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 15/4/24.
//

import CoreLocation
import MapKit
import SwiftUI

struct AdminScreen: View {
    @ObservedObject var profile: ProfileManager
    @State private var updated = false
    @State var startLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @State var user: User? = User()
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    LocationMap(profile: profile, updated: $updated, location: startLocation)
                } label: {
                    Label("Users Location", systemImage: "mappin.and.ellipse")
                }

                NavigationLink {
                    UserManagerView(selected: $user)

                } label: {
                    Label("Users Manager", systemImage: "person.2.badge.gearshape.fill")
                }

                NavigationLink {
                    NewUserView(completed: .constant(false))

                } label: {
                    Label("Add User", systemImage: "person.fill.badge.plus")
                }

                NavigationLink {
                    UserListBlockView(selected: $user)

                } label: {
                    Label("Block User", systemImage: "person.2.slash.fill")
                }

                Section {
                    NavigationLink {
                        EmployeeListView()

                    } label: {
                        Label("Stats", systemImage: "chart.bar.xaxis")
                    }

                    NavigationLink {
                        DateFilterView(profile: profile)

                    } label: {
                        Label("Leads by Dates", systemImage: "chart.bar.xaxis")
                    }

                } header: {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

                Section {
                    NavigationLink {
                        DateFilter2View(profile: profile)

                    } label: {
                        Label("Appointments by Dates", systemImage: "list.bullet")
                    }
                } header: {
                    Label("Reports", systemImage: "list.bullet")
                }
            }
            .navigationTitle("Admin")
        }
    }
}

struct AdminScreen2: View {
    @ObservedObject var profile: ProfileManager
    @State private var updated = false
    @State var startLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @State var user: User? = User()
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        DateFilterView(profile: profile)

                    } label: {
                        Label("Leads by Dates", systemImage: "chart.bar.xaxis")
                    }

                } header: {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

                Section {
                    NavigationLink {
                        DateFilter2View(profile: profile)

                    } label: {
                        Label("Appointments by Dates", systemImage: "list.bullet")
                    }
                } header: {
                    Label("Reports", systemImage: "list.bullet")
                }
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    MainAppScreenPreview()
}
