//
//  MyStatus.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/5/24.
//

import SwiftUI

struct LeadStatusView: View {
    @Binding var status: StatusId
    
    @State var sta: StatusType = .appt
    @State private var isModalPresented = false
    
    var statusList: [StatusId]
    var body: some View {
        HStack {
            VStack {
                SuperIcon2(status: $sta)
                
                    .frame(width: 50, height: 50)
                Text(status.name)
                    .frame(width: 50, height: 30)
            }.onTapGesture {
                isModalPresented.toggle()
            }
            .onAppear {
                sta = getStatusType(from: status.name)
            }
            .onChange(of: status.name) { newStatus in
                
                sta = getStatusType(from: newStatus)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(statusList, id: \._id) { item in
                        
                        VStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                            
                                .frame(width: 30, height: 30)
                                .padding(5)
                                .onTapGesture {
                                    status = item
                                }
                            Text(item.name)
                                .frame(width: 50, height: 30)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(5)
            
        }.padding(0)
            .sheet(isPresented: $isModalPresented) {
                VStack {
                    SuperIcon2(status: $sta)
                    
                        .frame(width: 50, height: 50)
                    Text("Status: \(status.name)")
                }
                .padding(10)
                Divider()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(statusList, id: \._id) { item in
                            VStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                                    .onTapGesture {
                                        status = item
                                        isModalPresented.toggle()
                                    }
                                
                                Text(item.name)
                                    .frame(width: 50, height: 30)
                                // .foregroundColor(.blue)
                            }.padding(0)
                        }
                    }
                }
                .padding(30)
                
                Button("back") {
                    isModalPresented.toggle()
                }
            }.padding(0)
    }
}
