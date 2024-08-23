//
//  LeadWorkOrder.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 17/7/24.
//

import SwiftUI

struct MyModel: Codable {
    var date: Date

    enum CodingKeys: String, CodingKey {
        case date
    }

    init(
        date: Date) {
        self.date = date
    }
}

struct OrderFormView2: View {
    // @ObservedObject var orderManager: OrderManager

    @Binding var order: OrderModel

    var body: some View {
        Form {
            Section(header: Text("Buyer1 Information")) {
            }
        }
    }
}

struct LeadWorkOrder: View {
    var profile: ProfileManager
    @State var lead: LeadModel
    @Binding var order: OrderModel
    @State var leadId: String = ""

    @StateObject var orderManager: OrderManager = .init()
    @State var mode = 1

    var body: some View {
        OrderFormView(orderManager: orderManager, order: $order, mode: mode)
            .environmentObject(profile)

            .onAppear {
                // order = OrderModel()
                Task {
                    order = await orderManager.details(leadId: lead.id)

                    order.lead = lead.id

                    if order._id != "" {
                        mode = 2
                    } else {
                        order.buyer1.name = "\(lead.first_name) \(lead.last_name)"
                        order.buyer1.phone = "\(lead.phone)"
                        order.buyer1.cel = "\(lead.phone2)"
                        order.address = lead.street_address
                        order.state = lead.state
                        order.city = lead.city
                        order.zip = lead.zip
                    }
                }

            }
    }
}

/*
 #Preview {
     //LeadWorkOrder(leadId: "6655ea4959ba342905ef1c52")
     MyLead()
 }
 */
