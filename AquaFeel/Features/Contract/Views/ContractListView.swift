//
//  ContractListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct ContractListView: View {
    var body: some View {
        NavigationStack {
            
            
            Form {
                NavigationLink {
                    OrderListView()
                } label: {
                    Label("Work Order", systemImage: "scroll.fill")
                }
                
                NavigationLink {
                    CreditListView()
                } label: {
                   
                    if #available(iOS 17.0, *) {
                        Label("Credit Application", systemImage: "creditcard.trianglebadge.exclamationmark.fill")
                    } else {
                        Label("Credit Application", systemImage: "creditcard")
                    }
                }//.disabled(true)
                
                NavigationLink {
                    CreditCardListView()
                } label: {
                    Label("Credit Card Authorization", systemImage: "creditcard.fill")
                }//.disabled(true)
                
                /*
                NavigationLink {
                    TestPDF()
                } label: {
                    Label("test PDF", systemImage: "creditcard.fill")
                }
                
                */
                /*
                NavigationLink {
                    BrandListView()
                } label: {
                    Label("Brands List", systemImage: "folder.fill.badge.plus")
                }
                
                
                NavigationLink {
                    ModelListView()
                } label: {
                    Label("Models List", systemImage: "tray.full.fill")
                }
                */
            }
        }
    }
}

#Preview {
    ContractListView()
}
