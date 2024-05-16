//
//  EmployeeListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/4/24.
//

import Charts
import SwiftUI

struct EmployeeListView: View {
    @StateObject var statsManager = StatsManager()

    @EnvironmentObject var profile: ProfileManager
    @State var loaded = false
    
    @State private var searchText = ""
    
    var filteredUsers: [EmployeeStats] {
        if searchText.isEmpty {
            return statsManager.stats
        } else {
            return statsManager.stats.filter { $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            
            
            
            if statsManager.count == nil {
                ProgressView("Loading...")
            }else{
                List(filteredUsers, id: \.id) { employee in
                    
                    NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                        VStack(alignment: .leading) {
                            Text("\(employee.firstName) \(employee.lastName)")
                                .font(.headline)
                            Text("Role: \(employee.role)")
                                .font(.subheadline)
                        }
                    }
                    
                }
                .searchable(text: $searchText)
               
            }
        }
        
        .navigationTitle("Users")

        .onAppear {
            if !loaded {
                Task {
                    statsManager.setProfile(profile: profile)

                    try? await statsManager.load()

                    loaded = true
                }
            }
        }
    }
}

struct EmployeeDetailView: View {
    let employee: EmployeeStats

    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading) {
            Text("Name: \(employee.firstName) \(employee.lastName)")
                .font(.headline)
            Text("Role: \(employee.role)")
                .font(.subheadline)

            Divider()
            Text("Leads:")
                .font(.headline)
            Chart {
                ForEach(employee.stats.chart) { x in

                    BarMark(
                        x: .value("Total Count", x.count),
                        y: .value("Shape Type", x.name)
                    )
                    .foregroundStyle(x.color)
                    
                    // .foregroundStyle(by: .value("Type", x.name))
                    .annotation(position: .trailing) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: x.name))
                                .frame(width: 24, height: 24)
                            Text(String(x.count))
                                //.foregroundColor(.gray)
                        }
                    }
                }
            }
            .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : .white)
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
        }
        
        .padding()
        .navigationTitle("Statistics")
    }
}

struct StatRow: View {
    let statName: String
    let statValue: String

    var body: some View {
        HStack {
            Text(statName)
                .font(.subheadline)
            Spacer()
            Text(statValue)
                .font(.subheadline)
        }
    }
}

#Preview {
    MainAppScreenPreview()
}

/*
 #Preview {
     EmployeeListView()
 }
 */
