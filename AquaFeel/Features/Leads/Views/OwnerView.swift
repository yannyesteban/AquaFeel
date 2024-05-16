//
//  OwnerView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/5/24.
//

import SwiftUI
/*
 
 
 struct TextWithIcon: View {
 let text: String
 
 var body: some View {
 HStack {
 SuperIconViewViewWrapper(status: getStatusType(from: "NHO"))
 .frame(width: 30, height: 30)
 }
 }
 }
 
 */
struct OwnerView: View {
    @State var text = ""
    @Binding var owner: CreatorModel
    @StateObject private var viewModel = CreatorManager()
    @ObservedObject var adminManager = AdminManager()
    // @State var selectedCreator
    
    var body: some View {
        HStack {
            if owner._id == "" {
                Text(text)
                    .foregroundColor(.secondary.opacity(0.7))
            } else {
                Text("\(owner.firstName) \(owner.lastName)")
            }
        }
        
        // .frame(width: .infinity, height: .infinity)
        .onTapGesture {
            viewModel.showCreatorList()
        }
        .sheet(isPresented: $viewModel.shouldDismissSheet) {
            CreatorListView(selected: $owner, viewModel: viewModel, adminManager: adminManager)
        }.onReceive(viewModel.$selectedCreator) { _ in
        }
    }
}
