//
//  PP.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 25/2/24.
//

import Foundation


//
//  Published.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 25/2/24.
//

import SwiftUI
import Combine



class LeadM: ObservableObject {
    
    @Published var textFilter: String = ""
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
     // Aquí suscribimos a los cambios de textFilter
     $textFilter
     .debounce(for: .seconds(5.5), scheduler: RunLoop.main) // opcional: debounce para esperar un tiempo después de la última edición
     .sink { [weak self] newValue in
     // Aquí puedes realizar la lógica que deseas cada vez que textFilter cambie
     self?.handleTextFilterChange(newValue)
     }
     .store(in: &cancellables)
     }
    
    private func handleTextFilterChange(_ newValue: String) {
        // Aquí puedes colocar la lógica que deseas realizar cuando textFilter cambie
        print("textFilter changed to: \(newValue)")
    }
}


struct PP: View {
    @StateObject var lead = LeadM()
    
    var body: some View {
        VStack {
            TextField("Search by...", text: $lead.textFilter)
            // Otras vistas y elementos de la interfaz de usuario aquí
        }
        .padding()
    }
}

#Preview {
    PP()
}
