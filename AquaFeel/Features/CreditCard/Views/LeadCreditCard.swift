//
//  LeadCredit.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import SwiftUI

struct LeadCreditCard: View {
    var profile: ProfileManager
    @State var lead: LeadModel
    @Binding var creditCard: CreditCardModel
    @State var leadId: String = ""
    
    @StateObject var orderManager: CreditCardManager = .init()
    @State var mode = 1
    
    var body: some View {
        CreditCardFormView(creditManager: orderManager, credit: $creditCard, mode: mode)
            .environmentObject(profile)
        
            .onAppear {
               
                Task {
                    creditCard = await orderManager.details(leadId: lead.id)
                    
                    creditCard.lead = lead.id
                    
                  
                    
                    if creditCard._id != "" {
                        mode = 2
                    } else {
                        creditCard.firstName = lead.first_name
                        creditCard.lastName = lead.last_name
                        creditCard.phone = lead.phone
                        
                        creditCard.address = lead.street_address
                        creditCard.state = lead.state
                        creditCard.city = lead.city
                        creditCard.zip = lead.zip
                    }
                }
                
                // order = orderManager.order
            }
    }
}


