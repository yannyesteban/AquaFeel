//
//  RouteListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/3/24.
//

import SwiftUI

struct RouteListView: View {
    var profile: ProfileManager
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
                        RouteView(profile: profile, routeManager: routeManager, mode: .new, id: "0", leads: [])

                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
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
    RouteListView(profile: ProfileManager())
}
