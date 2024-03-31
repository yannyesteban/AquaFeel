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
    @State var info = false

    @State var showFilter = false

    @State var location: CLLocationCoordinate2D

    var body: some View {
        GeometryReader { _ in

            HomeMapsRepresentable(location: $location, leadManager: leadManager, homeManager: homeManager)
                .edgesIgnoringSafeArea(.all)
            
                .overlay(alignment: .topLeading) {
                    VStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "pin.fill")
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
                            homeManager.setLassoTool()
                        }) {
                            Image(systemName: "hand.draw.fill")
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
            

        }.sheet(isPresented: $showFilter) {
            FilterOption(filter: $leadManager.filter, filters: $leadManager.leadFilter, statusList: leadManager.statusList, usersList: leadManager.users) {
                // lead.reset()
                leadManager.resetFilter()
                leadManager.runLoad()
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
