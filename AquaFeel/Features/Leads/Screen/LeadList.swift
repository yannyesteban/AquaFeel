//
//  LeadList.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 10/2/24.
//

import SwiftUI

struct LeadList: View {
    @Binding var leads: [LeadModel]
    @State var filter: String = ""
    
    @State private var isCreateLeadActive = false
    
    var body: some View {
        
        
        
        
        
        List(leads.indices, id: \.self) { index in
            
            
            
            NavigationLink(destination:  CreateLead(lead: $leads[index])) {
                HStack{
                    SuperIconViewViewWrapper(status: getStatusType(from: leads[index].status_id.name))
                        .frame(width: 34, height: 34)
                    VStack(alignment: .leading) {
                        
                        Text("\(leads[index].first_name) \(leads[index].last_name)" )
                        //.fontWeight(.semibold)
                        //.foregroundStyle(.blue)
                        
                        Text( "\(leads[index].street_address)")
                            .foregroundStyle(.gray)
                        
                    }
                    
                }
                
            }
            
        }
        
        
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing){
                
                
                Button{
                    
                    
                }label: {
                    Label("Eliminar", systemImage: "plus")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }
        
        HStack {
            //NavigationLink(destination:  CreateLead(lead: $leads[0])) {
            Button(action: {
                // Acción para mostrar la ventana modal con filtros
                //isFilterModalPresented.toggle()
            }) {
                Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            .padding()
            //}
        }
        
        
        
        
        
    }
}

struct testLeadList: View {
    
    @State private var isCreateLeadActive = false
    @State var filter = ""
    
    @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    
    @State private var isFilterModalPresented = false
    var body: some View {
        NavigationStack {
            
            
            
            List($lead.leads.indices, id: \.self) { index in
                
                
                
                NavigationLink(destination:  CreateLead(lead: $lead.leads[index])) {
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
            .navigationBarTitle("Leads List")
            
            HStack {
                VStack {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    
                    
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
            }.toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    
                    
                    Button{
                        
                        
                    }label: {
                        Label("Eliminar", systemImage: "plus")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            }
            //HStack{
            /*Divider()
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
                /*Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                 .foregroundColor(.blue)
                 .font(.system(size: 20))*/
            }
            .padding()
        }
        
        
        
        
        
    }
    
    
}

#Preview {
    testLeadList()
}
