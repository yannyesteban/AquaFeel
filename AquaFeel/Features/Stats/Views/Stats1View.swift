//
//  Stats1View.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/6/24.
//

import Charts
import SwiftUI

struct Stats1View: View {
    @StateObject var statsManager = StatsManager()

    @EnvironmentObject var profile: ProfileManager
    @State var loaded = false

    @State private var searchText = ""

    var filteredUsers: [StatsModel1] {
        if searchText.isEmpty {
            return statsManager.stats1
        } else {
            return statsManager.stats1.filter { $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            if statsManager.count == nil {
                ProgressView("Loading...")
            } else {
                List(filteredUsers, id: \.id) { employee in

                    NavigationLink(destination: Stats1DetailView(employee: employee)) {
                        VStack(alignment: .leading) {
                            Text("\(employee.firstName) \(employee.lastName)")
                                .font(.headline)

                            HStack {
                                Text("Role: \(employee.role)")
                                    .font(.subheadline)
                                Spacer()
                                Text("Total: \(employee.totalCount)")
                                    .font(.subheadline)
                            }
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

                    // try? await statsManager.load()
                    try? await statsManager.load1()
                    loaded = true
                }
            }
        }
    }
}

struct Stats1DetailView: View {
    let employee: StatsModel1

    @Environment(\.colorScheme) var colorScheme

    var orderedStats: [Stats1] {
        print("yanny")

        let allStatus: [StatusType] = [.uc, .ni, .ingl, .rent, .r, .appt, .demo, .win, .nho, .sm, .nm, .mycl, .r2]

        // Create a dictionary from the existing stats for quick lookup
        let statsDict = Dictionary(uniqueKeysWithValues: employee.stats.map { ($0.name, $0.count) })
        print(" -- ", statsDict)
        // Create an ordered array using allStatus and filling with zero if the status does not exist
        let x: [Stats1] = allStatus.map { status in
            Stats1(name: status.rawValue, count: statsDict[status.rawValue] ?? 0)
        }

        return x
    }

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
                ForEach(employee.orderedStats, id: \.name) { x in

                    BarMark(
                        x: .value("Total Count", x.count),
                        y: .value("Shape Type", x.name)
                    ).foregroundStyle(StatsManager.getColor(name: x.name))

                        .annotation(position: .trailing) {
                            HStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: x.name))
                                    .frame(width: 24, height: 24)
                                Text(String(x.count))
                                // .foregroundColor(.gray)
                            }
                        }
                }

                /* ForEach(employee.stats.chart) { x in

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
                             // .foregroundColor(.gray)
                         }
                     }
                 } */
            }
            .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : .white)
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
        }

        .padding()
        .navigationTitle("Statistics")
    }
}

struct Stat1Row: View {
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
