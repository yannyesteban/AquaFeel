//
//  OrderView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/6/24.
//

import SwiftUI

import SwiftUI

struct OrderView: View {
    @ObservedObject var viewModel: OrderManager
    
    var body: some View {
        VStack {
            
            Text("Order Details")
                .font(.largeTitle)
                .padding()
            
            // Buyer Information
            Section(header: Text("Buyer Information")) {
                Text("Buyer 1: \(viewModel.order.buyer1.name)")
                Text("Phone: \(viewModel.order.buyer1.phone)")
                Text("Cell: \(viewModel.order.buyer1.cel)")
                
                Text("Buyer 2: \(viewModel.order.buyer2.name)")
                Text("Phone: \(viewModel.order.buyer2.phone)")
                Text("Cell: \(viewModel.order.buyer2.cel)")
            }
            .padding()
            
            // Address Information
            Section(header: Text("Address Information")) {
                Text("Address: \(viewModel.order.address)")
                Text("City: \(viewModel.order.city)")
                Text("State: \(viewModel.order.state)")
                Text("ZIP: \(viewModel.order.zip)")
            }
            .padding()
            
            // System Information
            Section(header: Text("System Information")) {
                Text("System 1: \(viewModel.order.system1.name)")
                Text("Brand: \(viewModel.order.system1.brand)")
                Text("Model: \(viewModel.order.system1.model)")
                
                Text("System 2: \(viewModel.order.system2.name)")
                Text("Brand: \(viewModel.order.system2.brand)")
                Text("Model: \(viewModel.order.system2.model)")
                
                Text("Promotion: \(viewModel.order.promotion)")
            }
            .padding()
            
            // Installation Information
            Section(header: Text("Installation Information")) {
                Text("Installation Day: \(viewModel.order.installation.day)")
                Text("Date: \(viewModel.order.installation.date, formatter: dateFormatter)")
                Text("Ice Maker: \(viewModel.order.installation.iceMaker ? "Yes" : "No")")
                Text("Time: \(viewModel.order.installation.time) hours")
            }
            .padding()
            /*
            // Price Information
            Section(header: Text("Price Information")) {
                Text("Cash Price: \(viewModel.order.price.cashPrice)")
                Text("Installation: \(viewModel.order.price.installation)")
                Text("Taxes: \(viewModel.order.price.taxes)")
                Text("Total Cash: \(viewModel.order.price.totalCash)")
                Text("Down Payment: \(viewModel.order.price.downPayment)")
                Text("Amount to Finance: \(viewModel.order.price.toFinance)")
                Text("APR: \(viewModel.order.price.APR)%")
                Text("Finance Charge: \(viewModel.order.price.finaceCharge)")
                Text("Total of Payments: \(viewModel.order.price.totalCash + viewModel.order.price.finaceCharge)")
            }
            .padding()
            */
            Spacer()
        }
    }
    
    // Date formatter for displaying the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        let buyer1 = BuyerModel(id: "1", name: "John Doe", phone: "123-456-7890", cel: "098-765-4321")
        let buyer2 = BuyerModel(id: "2", name: "Jane Smith", phone: "123-456-7890", cel: "098-765-4321")
        let system1 = SystemModel(id: "1", name: "Water Purifier", brand: "AquaBrand", model: "Model X")
        let system2 = SystemModel(id: "2", name: "Water Softener", brand: "AquaBrand", model: "Model Y")
        let installation = InstallModel(id: "1", day: "Monday", date: Date(), iceMaker: true, time: 2)
        let terms = TermsModel(unit: "months", amount: 12)
        let price = PriceModel(cashPrice: 1000, installation: 100, taxes: 80, totalCash: 1180, downPayment: 180, toFinance: 1000, terms: terms, APR: 5, finaceCharge: 50)
        let order = OrderModel(id: "1", buyer1: buyer1, buyer2: buyer2, address: "123 Main St", city: "Metropolis", state: "NY", zip: "12345", system1: system1, system2: system2, installation: installation, people: 3, creditCard: true, check: false, price: price)
        
        //OrderView(viewModel: OrderManager(order: order))
    }
}
