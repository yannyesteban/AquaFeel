//
//  BrandListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import SwiftUI

struct BrandListView: View {
    @StateObject var brandManager: BrandManager = .init()
    @State var brand = BrandModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($brandManager.brands, id: \._id) { $item in
                    NavigationLink {
                        BrandFormView(brandManager: brandManager, brand: $item)
                    } label: {
                        HStack {
                            Image(systemName: "scroll.fill")
                            VStack(alignment: .leading) {
                                Text(item.name)
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Brands List")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // ToolbarItemGroup(placement: .automatic){
                
                NavigationLink {
                    
                    
                    
                    BrandFormView(brandManager: brandManager, brand: $brand, mode: 1)
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            // routeManager.userId = profile.userId
            
            Task {
                await brandManager.list(userId: "xxx")
            }
        }
    }
}


#Preview {
    BrandListView()
}
