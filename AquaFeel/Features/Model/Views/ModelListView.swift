//
//  ModelListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import SwiftUI

struct ModelListView: View {
    @StateObject var modelManager: ModelManager = .init()
    @State var model = ModelModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($modelManager.models, id: \._id) { $item in
                    NavigationLink {
                        ModelFormView(modelManager: modelManager, model: $item)
                    } label: {
                        HStack {
                            Image(systemName: "scroll.fill")
                            VStack(alignment: .leading) {
                                Text(item.brand.name)
                                Text(item.name)
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Models List")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){
                
                NavigationLink {
                    
                    
                    
                    ModelFormView(modelManager: modelManager, model: $model, mode: 1)
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            // routeManager.userId = profile.userId
            
            Task {
                await modelManager.list(userId: "xxx")
            }
        }
    }
}
