//
//  CreditCardListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import SwiftUI

struct CreditCardListView: View {
    @StateObject var creditManager: CreditCardManager = .init()
    @State var credit = CreditCardModel()
    @EnvironmentObject var profile: ProfileManager
    var body: some View {
        NavigationStack {
            List {
                ForEach($creditManager.creditCards, id: \._id) { $item in
                    NavigationLink {
                        CreditCardFormView(creditManager: creditManager, credit: $item)
                    } label: {
                        HStack {
                            Image(systemName: "scroll.fill")
                            VStack(alignment: .leading) {
                                Text(item.firstName)
                                //Text(item.createdOn.formattedDate())
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Credit Card Authorizations")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){
                
                NavigationLink {
                    
                    
                    
                    CreditCardFormView(creditManager: creditManager, credit: $credit, mode: 1)
                    
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

#Preview {
    CreditCardListView()
}
