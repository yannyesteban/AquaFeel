//
//  LeadPicker.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct LeadPicker: View {
    var profile: ProfileManager

    @State private var isCreateLeadActive = false
    @State var filter = ""

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager()

    @State private var isFilterModalPresented = false

    @State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()

    @Binding var selectedLeads: [LeadModel]
    // @State var selectedLeads: Set<LeadModel> = []

    // @EnvironmentObject var store: MainStore<UserData>
    func toggleLeadSelection(_ lead: LeadModel) {
        if let index = selectedLeads.firstIndex(of: lead) {
            selectedLeads.remove(at: index) // Si ya está seleccionado, lo eliminamos
        } else {
            selectedLeads.append(lead) // Si no está seleccionado, lo añadimos
        }
    }

    func loadMoreContent() {
        if !isLoading {
            isLoading = true
            // This simulates an asynchronus call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let moreNumbers = numbers.count + 1 ... numbers.count + 20
                numbers.append(contentsOf: moreNumbers)
                isLoading = false
                if numbers.count > 250 {
                    isFinished = true
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    HStack {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                // .fontWeight(.semibold)
                                // .foregroundStyle(.blue)

                                Text("\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                            }
                            Spacer()

                            // Agregar el icono SF Symbol para indicar la selección
                            Image(systemName: selectedLeads.contains(manager.leads[index]) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedLeads.contains(manager.leads[index]) ? .blue : .gray)
                                .onTapGesture {
                                    // Cambiar el estado de selección del lead cuando se hace tap
                                    toggleLeadSelection(manager.leads[index])
                                }
                        }
                    }
                }

                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .foregroundColor(.red)
                    .onAppear {
                        manager.list()
                    }
            }

            /* List($lead.leads.indices, id: \.self) { index in

             NavigationLink(destination:  CreateLead(lead: $lead.leads[index], manager: lead2){}) {
             HStack{
             SuperIconViewViewWrapper(status: getStatusType(from: lead.leads[index].status_id.name))
             .frame(width: 34, height: 34)
             VStack(alignment: .leading) {

             Text("\(lead.leads[index].first_name) \(lead.leads[index].last_name)" )
             //.fontWeight(.semibold)
             //.foregroundStyle(.blue)

             Text( "\(lead.leads[index].street_address)")
             .foregroundStyle(.gray)

             }

             }

             }

             } */

            .onAppear {
                manager.userId = profile.userId
                manager.role = profile.role
                manager.token = profile.token

                manager.initFilter(completion: { _, _ in

                })
            }

            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        manager.reset()
                        manager.load(count: 9)

                    } label: {
                        HStack {
                            // Text("Reset")
                            Image(systemName: "gobackward")
                        }
                        // .font(.caption)
                        // .fontWeight(.bold)
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Leads")

            HStack {
                VStack {
                    Divider()
                        .padding(.horizontal, 20)
                    /*
                     .toolbar {
                     ToolbarItem(placement: .automatic) {
                     // ToolbarItemGroup(placement: .automatic){

                     NavigationLink {
                     CreateLead(lead: $lead, mode: 1, manager: manager, userId: userId) { _ in
                     }

                     } label: {
                     Image(systemName: "plus")
                     }
                     }
                     }
                     */
                    // .toolbarBackground(.hidden, for: .navigationBar)

                    TextField("search by...", text: $manager.filter.textFilter)
                        .onChange(of: manager.filter.textFilter, perform: { _ in

                            // lead.textFilter = "pedro alejandro"
                            searchTimer?.invalidate()

                            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                                /* let leadQuery = LeadQuery()
                                 .add(.limit, "30")
                                 .add(.searchKey, "all")
                                 .add(.offset, "0")
                                 .add(.limit, "40")
                                 .add(.searchValue, newSearchText)
                                 // lead2.loadAll(query:leadQuery)
                                 */
                                manager.search()
                            }

                        })
                        .padding(.bottom, 5).padding(.horizontal, 20)
                    Divider()
                        .padding(.bottom, 10)
                        .padding(.horizontal, 20)
                }

                Button(action: {
                    // Acción para mostrar la ventana modal con filtros
                    isFilterModalPresented.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                .padding()
            }
            // HStack{
            /* Divider()
             .padding(.horizontal, 20)

             //.overlay(VStack{Divider().offset(x: 0, y: 15)})
             Divider()
             .padding(.bottom, 10)
             .padding(.horizontal, 20)
             */

            // }

        }.sheet(isPresented: $isFilterModalPresented) {
            FilterOption(profile: profile, filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                manager.reset()
            }
            .onAppear {
                // lead2.statusAll()
            }

            Button(action: {
                // Acción para mostrar la ventana modal con filtros
                isFilterModalPresented.toggle()
            }) {
                Text("Close")
                /* Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                 .foregroundColor(.blue)
                 .font(.system(size: 20)) */
            }
            .padding()
        }

        .onAppear {
            manager.userId = profile.userId
            manager.token = profile.token
            manager.role = profile.role
        }
    }
}
