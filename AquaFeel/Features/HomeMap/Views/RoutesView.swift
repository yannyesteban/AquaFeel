//
//  RoutesView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 10/4/24.
//

import SwiftUI

struct RoutesView: View {
    var profile: ProfileManager
    @ObservedObject var routeManager = RouteManager()

    @Binding var selected: Bool
    @Binding var routeId: String?

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            List {
                ForEach(routeManager.routes, id: \._id) { route in

                    /*

                     NavigationLink {

                         RouteMapScreen(profile: profile, routeId: route._id, updated: .constant(false), leadManager: LeadManager())

                     } label: {
                         HStack {
                             VStack(alignment: .center) {
                                 Image(systemName: "car.fill")
                                     .resizable()
                                     .scaledToFit()

                                     .foregroundColor(.primary)
                                     .frame(width: 30)

                                 Text("Stop: \(route.leads.count)")
                                     .font(.subheadline)
                             }
                             .foregroundColor(.primary)

                             VStack(alignment: .leading) {
                                 Text(route.name)

                                 DateLocalView(dateString: route.createdOn, showTime: false)

                             }
                         }
                     }
                     */
                    NavigationLink {
                        Text(route._id)
                    } label: {
                        HStack {
                            VStack(alignment: .center) {
                                Image(systemName: "car.fill")
                                    .resizable()
                                    .scaledToFit()

                                    .foregroundColor(.accentColor)
                                    .frame(width: 30)

                                Text("Stop: \(route.leads.count)")
                                    .font(.subheadline)
                            }
                            // .foregroundColor(.primary)

                            VStack(alignment: .leading) {
                                Text(route.name)

                                DateLocalView(dateString: route.createdOn, showTime: false)
                            }
                            .padding(.horizontal, 20)
                        }
                        .onTapGesture {
                            DispatchQueue.main.async {
                                self.routeId = route._id
                                self.selected = true
                            }
                            presentationMode.wrappedValue.dismiss()
                            /* Task {
                             routeManager.mapRoute = try! await routeManager.getRoute(routeId: route._id)!
                             print(routeManager.mapRoute)
                             } */
                        }
                    }
                }
            }
            // .navigationTitle("Create Lead")
            .navigationBarTitle("Route List")
            /*.toolbar {
                ToolbarItem(placement: .automatic) {
                    // ToolbarItemGroup(placement: .automatic){

                    NavigationLink {
                        RouteView(profile: profile, routeManager: routeManager, mode: .new, id: "0", leads: [])

                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }*/
            .onAppear {
                routeManager.userId = profile.userId

                Task {
                    do {
                        // try await detail(routeId: "64c82646b6b8eb6360a05382" )
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
    RoutesView(profile: ProfileManager(), selected: .constant(false), routeId: .constant(""))
}
