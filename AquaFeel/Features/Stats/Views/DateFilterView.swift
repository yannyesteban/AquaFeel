//
//  DateFilterView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/4/24.
//

import Charts
import SwiftUI

struct DateFilterView: View {
    @ObservedObject var profile: ProfileManager
    @StateObject var statsManager = StatsManager()
    @Environment(\.colorScheme) var colorScheme
    @State var waiting = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                DatePicker(
                    "From",
                    selection: $statsManager.filter.fromDate,
                    displayedComponents: [.date]
                )

                DatePicker(
                    "To",
                    selection: $statsManager.filter.toDate,
                    displayedComponents: [.date]
                )
            }
            if waiting {
                ProgressView()
            } else {
                Toggle(isOn: $statsManager.showAll) {
                    HStack {
                        Text("Show all status")
                    }
                }
                // .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .onChange(of: statsManager.showAll) { _ in
                    Task {
                        waiting = true
                        try? await statsManager.groupByStatus()
                        waiting = false
                    }
                }

                Button(action: {
                    Task {
                        waiting = true
                        try? await statsManager.groupByStatus()
                        waiting = false
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Next")

                        Image(systemName: "arrowshape.forward.fill")
                    }
                }
            }

            Chart {
                ForEach(statsManager.items) { x in

                    BarMark(
                        x: .value("Total Count", x.count),
                        y: .value("Shape Type", x.name)
                    )
                    .foregroundStyle(x.color)

                    // .foregroundStyle(by: .value("Type", x.name))
                    .annotation(position: .trailing) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: x.name))
                                .frame(width: 20, height: 20)
                            Text(String(x.count))
                                .font(.callout)
                            // .foregroundColor(.gray)
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
        .onAppear{
            statsManager.setProfile(profile: profile)
        }
    }
}

struct DateFilter2View: View {
    @ObservedObject var profile: ProfileManager
    @StateObject var statsManager = StatsManager()
    @Environment(\.colorScheme) var colorScheme
    @State var waiting = false
    @State var items: [String: [LeadModel]] = [:]
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .center) {
                    DatePicker(
                        "From",
                        selection: $statsManager.filter.fromDate,
                        displayedComponents: [.date]
                    )

                    DatePicker(
                        "To",
                        selection: $statsManager.filter.toDate,
                        displayedComponents: [.date]
                    )
                }

                if waiting {
                    ProgressView()
                } else {
                    Button(action: {
                        Task {
                            waiting = true

                            items = await statsManager.appointmentByDate()

                            waiting = false

                          
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Next")

                            Image(systemName: "arrowshape.forward.fill")
                        }
                    }
                }
            }

            .padding()
            .navigationTitle("Appointment by Dates")

            List {
                ForEach(items.keys.sorted(), id: \.self) { item in
                    NavigationLink(destination: SimpleLeadListView(leads: items[item] ?? [])) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue) // Cambiar el color del icono si es necesario
                                .font(.system(size: 20)) // Cambiar el tamaño del icono si es necesario

                            Text("\(shortDate(statsManager.getDate(from: item)))")

                            Spacer() // Agregar un espacio flexible para empujar el siguiente texto al extremo derecho

                            Text("\(items[item]?.count ?? 0)")
                                .padding(.horizontal, 8) // Agregar relleno horizontal para un aspecto más bonito
                                .padding(.vertical, 4) // Agregar relleno vertical para un aspecto más bonito
                                .background(Color.blue) // Cambiar el color de fondo del recuento si es necesario
                                .foregroundColor(.white) // Cambiar el color del texto del recuento si es necesario
                                .cornerRadius(8) // Agregar esquinas redondeadas para un aspecto más bonito
                        }
                    }
                }
            }
            .padding(0)
        }
        .onAppear{
            statsManager.setProfile(profile: profile)
        }
    }
       
}

