//
//  OrderListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct OrderListView: View {
    @StateObject var orderManager: OrderManager = .init()
    @State var order = OrderModel()
    @EnvironmentObject var profile: ProfileManager
    var body: some View {
        NavigationStack {
            List {
                ForEach($orderManager.orders, id: \._id) { $item in
                    NavigationLink {
                        OrderFormView(orderManager: orderManager, order: $item)
                    } label: {
                        HStack {
                            Image(systemName: "scroll.fill")
                            VStack(alignment: .leading) {
                                Text(item.buyer1.name)
                                Text(item.installation.date.formattedDate())
                                // Text(formatDateToString( item.installation.date))
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Work Order List")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){

                NavigationLink {
                    
                   
                    
                    OrderFormView(orderManager: orderManager, order: $order, mode: 1)

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            // routeManager.userId = profile.userId

            Task {
                await orderManager.list(userId: profile.userId)
            }
        }
    }
}

#Preview {
    OrderListView()
}
