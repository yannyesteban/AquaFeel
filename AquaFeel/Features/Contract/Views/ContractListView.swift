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
                    Text("Credit Aplication")
                } label: {
                    Label("Credit Aplication", systemImage: "creditcard.fill")
                }.disabled(true)
                /*
                NavigationLink {
                    TestPDF()
                } label: {
                    Label("test PDF", systemImage: "creditcard.fill")
                }
                
                */
                
            }
        }
    }
}

#Preview {
    ContractListView()
}
