//
//  PathOptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 6/2/24.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct PathOptionView: View {
    var profile: ProfileManager

    @Binding var leads: [LeadModel]
    @State var path: GMSMutablePath
    @ObservedObject var leadManager: LeadManager
    @Binding var updated: Bool

    @State private var groupedLeads: [String: Int] = [:] // Propiedad para almacenar los resultados
    @StateObject var statusManager = StatusManager()
    @StateObject var routeManager = RouteManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Lasso Options")
                    .padding(.vertical, 20)

                if !leadManager.leadsInsidePath.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            Spacer()
                            ForEach(Array(groupedLeads.keys), id: \.self) { statusName in
                                let count = groupedLeads[statusName] ?? 0

                                VStack {
                                    SuperIconViewViewWrapper(status: getStatusType(from: statusName))
                                        .frame(width: 30, height: 30)
                                        .grayscale(!leadManager.selectedItems.contains(statusName) ? 0.9 : 0.0)
                                        .brightness(!leadManager.selectedItems.contains(statusName) ? 0.3 : 0.0)
                                    if leadManager.selectedItems.contains(statusName) {
                                        Text("\(count)")
                                    } else {
                                        Text("0").brightness(0.1)
                                    }
                                }
                                .padding(5)
                                .onTapGesture {
                                    toggleSelection(statusName)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                } else {
                    Text("No Data")
                }

                HStack {
                    NavigationButton(imageName: "app.connected.to.app.below.fill", label: "Route", badge: leadManager.filteredLeads.count) {
                        RouteView(profile: profile, routeManager: routeManager, mode: .new, id: "0", leads: leadManager.filteredLeads)
                    }
                    NavigationButton(imageName: "person.fill.checkmark", label: "Owner") {
                        ChangeUserView(leadManager: leadManager, adminManager: AdminManager(userId: profile.userId, token: profile.token, role: profile.role))
                    }.disabled(profile.role == "SELLER")

                    NavigationButton(imageName: "star.fill", label: "Status") {
                        ChangeStatusView(leadManager: leadManager, statusList: statusManager.statusList)
                    }
                    NavigationButton(imageName: "trash.fill", label: "Delete") {
                        DeleteLeadsView(leadManager: leadManager)
                    }
                }
                Text("Total Leads \(leads.count)")
            }

            .onChange(of: leadManager.updated) { value in
                updated = value
            }
            .onAppear {
                routeManager.userId = profile.userId
                
                loadDataAndProcess()
            }
            .onChange(of: leadManager.leads.count) { _ in
                //loadDataAndProcess()
            }
            .onChange(of: leadManager.selectedItems) { _ in
                updateLeads()
            }
        }
    }

    func updateLeads() {
        leadManager.filteredLeads = leadManager.leadsInsidePath.filter { lead in
            leadManager.selectedItems.contains(lead.status_id.name)
        }
    }

    func toggleSelection(_ statusName: String) {
        if leadManager.selectedItems.contains(statusName) {
            leadManager.selectedItems.remove(statusName)
        } else {
            leadManager.selectedItems.insert(statusName)
        }

        updateLeads()
    }

    private func loadDataAndProcess() {
        leadManager.doLeadsInsidePath(path: path)
        DispatchQueue.main.async {
            self.groupedLeads = self.leadManager.leadsInsidePath.reduce(into: [:]) { counts, lead in
                counts[lead.status_id.name, default: 0] += 1
            }
        }
        
        updateLeads()
    }
}

#Preview {
    MainAppScreenHomeScreenPreview()
}
