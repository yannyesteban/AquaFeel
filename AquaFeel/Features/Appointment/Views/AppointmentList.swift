//
//  AppointmentList.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/3/24.
//

import SwiftUI

enum LeadModeFilter {
    case all
    case today
    case last30
    
}
struct AppointmentList: View {
    var profile:ProfileManager
    
    @State private var isCreateLeadActive = false
    @State var filter = ""
    
   
    
    @StateObject var manager:AppointmentManager = AppointmentManager(filterMode: .all)
    //@StateObject var user = UserManager()
    
    
    @State private var isFilterModalPresented = false
    
    @State private var numbers: [Int] = Array(1...20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()
    @State var showLeads = false
    @State var filterMode: LeadModeFilter = .all
    @State var userId: String// = "DD2EMns3y"
    //@EnvironmentObject var store: MainStore<UserData>
    @State private var store = MainStore<UserData>() // AppStore()
    @StateObject var leadManager = LeadManager()
    
    func loadMoreContent() {
        if !isLoading {
            isLoading = true
            // This simulates an asynchronus call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let moreNumbers = numbers.count + 1...numbers.count + 20
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
                    NavigationLink(destination:  
                                   //Text("Nothing")
                                   CreateLead(profile: profile, lead: $manager.leads[index], mode: 2, manager: leadManager, userId: userId) {_ in}
                                  ) {
                        HStack{
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)" )
                                //.fontWeight(.semibold)
                                //.foregroundStyle(.blue)
                                
                                Text( "\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                                
                            }
                            
                        }
                        
                    }
                }.onAppear{
                    print("list count is", manager.leads.count)
                }
                
                
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .foregroundColor(.red)
                    .onAppear {
                        
                        //manager.list()
                    }
                
                
            }
            
            
            /*List($lead.leads.indices, id: \.self) { index in
             
             
             
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
             
             }*/
            
           
            
            
            .toolbar{
                ToolbarItemGroup(placement: .topBarLeading){
                    
                    
                    Button{
                        //manager.reset()
                        //manager.load(count: 9)
                        
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
            .navigationBarTitle("My Appointments")
            .toolbar{
                ToolbarItem(placement: .automatic){
                    //ToolbarItemGroup(placement: .automatic){
                    
                    
                    NavigationLink {
                        /*
                         CreateLead(lead: $lead, mode: 1, manager: manager){_ in
                         
                         }
                         */
                        
                    } label: {
                        
                        Image(systemName: "plus")
                    }
                }
            }
            
           
            
        }
        
        
        .onAppear{
            Task{
                
                
            }
               
            
        }
        
        .task {
            
            manager.showLeads = showLeads
            manager.filterMode = filterMode
            manager.userId = userId
            print("Task", manager.filterMode, userId)
            
            try? await manager.list()
            
            
            
        }
        .environmentObject(store)
    }
    
    
}


#Preview {
    AppointmentList(profile: ProfileManager(), filterMode: .all, userId: "123456")//DD2EMns3y"
}
