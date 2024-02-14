//
//  Authentication.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

//import Foundation
import SwiftUI

class Authentication: ObservableObject {
    @Published var isValidated = false
    
    func updateValidation(success: Bool){
        withAnimation {
            isValidated = success
        }
    }
}
