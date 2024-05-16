//
//  CreatorManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/5/24.
//

import Foundation

class CreatorManager: ObservableObject {
    @Published var selectedCreator: CreatorModel?
    @Published var creators: [CreatorModel] = []
    @Published var searchText = ""
    @Published var shouldDismissSheet: Bool = false
    
    func showCreatorList() {
        selectedCreator = nil
        shouldDismissSheet = true
    }
}
