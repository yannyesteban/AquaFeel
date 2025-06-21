//
//  LeadList.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 10/2/24.
//

import SwiftUI
/*
struct LeadList1: View {
    @Binding var leads: [LeadModel]
    @State var filter: String = ""

    @State private var isCreateLeadActive = false
    @ObservedObject var manager = LeadManager() // LeadViewModel(first_name: "Juan", last_name: "")

    var body: some View {
        List(leads.indices, id: \.self) { index in

            NavigationLink(destination: CreateLead(profile: ProfileManager(), lead: $leads[index], manager: manager, updated: .constant(false)) { _ in }) {
                HStack {
                    SuperIconViewViewWrapper(status: getStatusType(from: leads[index].status_id.name))
                        .frame(width: 34, height: 34)
                    VStack(alignment: .leading) {
                        Text("\(leads[index].first_name) \(leads[index].last_name)")
                        // .fontWeight(.semibold)
                        // .foregroundStyle(.blue)

                        Text("\(leads[index].street_address)")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }

        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }

        HStack {
            // NavigationLink(destination:  CreateLead(leadlead: $leads[0])) {
            Button(action: {
                // Acción para mostrar la ventana modal con filtros
                // isFilterModalPresented.toggle()
            }) {
                Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            .padding()
            // }
        }
    }
}
*/
struct LeadListScreen: View {
    var profile: ProfileManager
    @Binding var updated: Bool

    @State private var isCreateLeadActive = false
    @State var filter = ""

    //@StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager()

    @State private var isFilterModalPresented = false

    //@State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()

    @EnvironmentObject var store: MainStore<UserData>
    /*
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
     */
    var body: some View {
        /* NavigationStack {
             List{
                 ForEach(numbers, id: \.self) { number in
                     NavigationLink(destination: Text("Row \(number)")){
                         Text("Row \(number)")
                     }
                 }
                 if !isFinished {
                     ProgressView()
                         .frame(maxWidth: .infinity, maxHeight: .infinity)
                         .foregroundColor(.black)
                         .foregroundColor(.red)
                         .onAppear {
                             loadMoreContent()
                         }
                 }

             }

         } */
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    NavigationLink(destination: CreateLead(profile: profile, lead: $manager.leads[index], manager: manager, updated: $updated) { _ in }) {
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
                        }
                    }
                }.onAppear {
                    print("list count is", manager.leads.count)
                }

                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .foregroundColor(.red)
                    .onAppear {
                        Task {
                            try? await manager.list()
                        }
                        
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
                print("onAppear   ...")
                manager.initFilter(completion: { _, _ in

                })
                // let leadQuery = LeadQuery()
                // .add(.limit , "10")
                // .add(.searchKey, "all")
                // .add(.searchValue, "yanny")

                // lead.load(count: 3)
                // print(9999)
                // user.list(){}
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .favorite, userId: profile.info._id)
                        
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    NavigationLink {
                        CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, updated: $updated) { _ in
                        }
                        
                    } label: {
                        Image(systemName: "plus")
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
                                    CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, updated: $updated) { _ in
                                    }

                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }*/
                    // .toolbarBackground(.hidden, for: .navigationBar)

                    TextField("search by...", text: $manager.filter.textFilter)
                        .onChange(of: manager.filter.textFilter, perform: { newSearchText in

                            // lead.textFilter = "pedro alejandro"
                            searchTimer?.invalidate()

                            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in

                                let leadQuery = LeadQuery()
                                    .add(.limit, "30")
                                    .add(.searchKey, "all")
                                    .add(.offset, "0")
                                    .add(.limit, "40")
                                    .add(.searchValue, newSearchText)
                                // lead2.loadAll(query:leadQuery)

                                //manager.search()
                                Task {
                                    try? await manager.list()
                                }
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

/*
 struct LeadListScreen2: View {

     @State private var isCreateLeadActive = false
     @State var filter = ""

     @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")

     @State private var isFilterModalPresented = false
     var body: some View {
         NavigationStack {

             List($lead.leads.indices, id: \.self) { index in

                 NavigationLink(destination:  CreateLead(lead: $lead.leads[index], manager: lead){}) {
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

             }

             .onAppear(){

                 let leadQuery = LeadQuery()
                 //.add(.limit , "10")
                 //.add(.searchKey, "all")
                 //.add(.searchValue, "yanny")

                 lead.loadAll(query:leadQuery)
             }
             .toolbar{
                 ToolbarItemGroup(placement: .topBarLeading){

                     Button{

                     }label: {
                         HStack {

                             //Text("Reset")
                             Image(systemName: "gobackward")

                         }
                         //.font(.caption)
                         //.fontWeight(.bold)
                         .foregroundColor(.red)
                     }
                 }
             }
             .navigationBarTitle("Leads List")

             HStack {
                 VStack {
                     Divider()
                         .padding(.horizontal, 20)

                         .toolbar{
                             ToolbarItem(placement: .automatic){
                                 //ToolbarItemGroup(placement: .automatic){

                                 Button{

                                 }label: {
                                     Label("new", systemImage: "plus")
                                         .font(.title)
                                     //.foregroundColor(.red)
                                 }
                             }
                         }
                     //.toolbarBackground(.hidden, for: .navigationBar)

                     TextField("search by...", text: $filter)
                         .onChange(of: filter , perform: {newSearchText in
                             searchTimer?.invalidate()

                             searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in

                                 let leadQuery = LeadQuery()
                                     .add(.limit , "30")
                                     .add(.searchKey, "all")
                                     .add(.offset, "0")
                                     .add(.limit, "40")
                                     .add(.searchValue, newSearchText)
                                 lead.loadAll(query:leadQuery)
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
             //HStack{
             /* Divider()
              .padding(.horizontal, 20)

              //.overlay(VStack{Divider().offset(x: 0, y: 15)})
              Divider()
              .padding(.bottom, 10)
              .padding(.horizontal, 20)
              */

             //}

         }.sheet(isPresented: $isFilterModalPresented) {
             FilterOption(statusList: lead.statusList)
                 .onAppear{
                     lead.statusAll()
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

     }

 }

 */
/* #Preview {
     LeadListScreen()
 }

 */

#Preview {
    LeadListHomeScreenPreview()
}

struct LeadListHomeScreenPreview: View {
    @StateObject private var store = MainStore<UserData>() // AppStore()
    var body: some View {
        LeadListScreen(profile: ProfileManager(), updated: .constant(false))

            .environmentObject(store)
    }
}
