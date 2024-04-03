//
//  HomeMap.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct HomeMap: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    @EnvironmentObject var store: MainStore<UserData>

    @State var showSettings = true

    @ObservedObject var leadManager: LeadManager
    @StateObject var homeManager = HomeMapManager()
    @State var showInfo = false

    @State var showFilter = false

    @State var location: CLLocationCoordinate2D

    @StateObject var tool = ToolManager()

    @State var lassoEnded = false
    @State var markEnded = false
    @State var time = 0
    @State var lead = LeadModel()
    var body: some View {
        GeometryReader { _ in

            HomeMapsRepresentable(location: $location, leadManager: leadManager, homeManager: homeManager, tool: tool, time: $time)
                .edgesIgnoringSafeArea(.all)

                .overlay(alignment: .topLeading) {
                    VStack {
                        Button {
                            tool.toggle(.marker, .cluster)
                        } label: {
                            Image(systemName: tool.mode == .marker ? "eraser.fill" : "pin.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }

                        Button(action: {
                            tool.toggle(.lasso, .cluster)
                        }) {
                            Image(systemName: tool.mode == .lasso ? "eraser.fill" : "hand.draw.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }.padding(10)
                        
                        
                        
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showFilter = true
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterOption(filter: $leadManager.filter, filters: $leadManager.leadFilter, statusList: leadManager.statusList, usersList: leadManager.users) {
                // lead.reset()
                leadManager.resetFilter()
                leadManager.runLoad()
            }
        }

        .sheet(isPresented: $lassoEnded) {
            PathOptionView(profile: profile, leads: $leadManager.leads, path: $tool.lasso, leadManager: leadManager, updated: $updated)
                .presentationDetents([.fraction(0.35), .medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $markEnded) {
            CreateLead(profile: profile, lead: $lead, mode: 1, manager: leadManager, updated: .constant(false)) { result in
                if result {
                    // manager.leads.append(lead)
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                CreateLead(profile: profile, lead: $lead
                , mode: 0, manager: leadManager, updated: $updated) { _ in
                    print("on Saving")
                }
            }
            
            .presentationDetents([.fraction(0.2), .medium, .large])
            .presentationContentInteraction(.scrolls)
        }
        
        .onAppear{
            print("leadManager.userId: ", leadManager.userId)
        }

        .onReceive(tool.$ready) { ready in

            if ready {
                DispatchQueue.main.async {
                    switch tool.mode {
                    case .lasso:
                        lassoEnded = true
                    case .marker:

                        markEnded = true
                        DispatchQueue.main.async {
                            Task{
                                self.lead = try! await leadManager.newFromLocation(location: tool.marker.position)
                            }
                            
                        }
                    case .cluster:
                        showInfo = true
                        DispatchQueue.main.async {
                            if let userData = tool.marker.userData as? LeadModel {
                                // print(userData["name"] ?? "")
                                lead = userData
                            }
                        }
                       

                    default:
                        lassoEnded = false
                        
                    }
                    print("...tool.mode", tool.mode)
                }
            }
        }
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}

/*
 #Preview {
     HomeMap(profile: ProfileManager(), updated: .constant(false), manager: LeadManager(), location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) )
 }
 */
