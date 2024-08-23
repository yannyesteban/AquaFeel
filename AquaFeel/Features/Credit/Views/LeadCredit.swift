//
//  LeadCreditCard.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import SwiftUI

struct LeadCredit: View {
    var profile: ProfileManager
    @State var lead: LeadModel
    @Binding var credit: CreditModel
    @State var leadId: String = ""

    @StateObject var creditManager: CreditManager = .init()
    @State var mode = 1

    var body: some View {
        CreditFormView(creditManager: creditManager, credit: $credit, mode: mode)
            .environmentObject(profile)

            .onAppear {
                // order = OrderModel()
                Task {
                    credit = await creditManager.details(leadId: lead.id)

                    credit.lead = lead.id

                    

                    if credit._id != "" {
                        mode = 2
                    } else {
                        credit.applicant.firstName = lead.first_name
                        credit.applicant.lastName = lead.last_name
                        credit.applicant.phone = lead.phone
                        credit.applicant.cel = lead.phone2
                        credit.applicant.address = lead.street_address
                        credit.applicant.state = lead.state
                        credit.applicant.city = lead.city
                        credit.applicant.zip = lead.zip
                    }
                }

               
            }
    }
}
