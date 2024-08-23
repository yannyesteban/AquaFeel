//
//  CreditListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/7/24.
//

import SwiftUI

struct CreditListView: View {
    @StateObject var creditManager: CreditManager = .init()
    @State var credit = CreditModel()
    @EnvironmentObject var profile: ProfileManager
    var body: some View {
        NavigationStack {
            List {
                ForEach($creditManager.credits, id: \._id) { $item in
                    NavigationLink {
                        CreditFormView(creditManager: creditManager, credit: $item)
                    } label: {
                        HStack {
                            Image(systemName: "scroll.fill")
                            VStack(alignment: .leading) {
                                Text(item.applicant.firstName)
                                //Text(item.createdOn.formattedDate())
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Credit Application List")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){
                
                NavigationLink {
                    
                    
                    
                    CreditFormView(creditManager: creditManager, credit: $credit, mode: 1)
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            // routeManager.userId = profile.userId
            
            Task {
                await creditManager.list(userId: profile.userId)
            }
        }
    }
}

#Preview {
    CreditListView()
}
