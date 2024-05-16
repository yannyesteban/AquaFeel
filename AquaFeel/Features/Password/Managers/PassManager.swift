//
//  PassManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/4/24.
//

import Foundation

enum PassError: Error {
    case emailError
    case networkError
}

class PassManager: ObservableObject {
    
    @Published var user:User = User()
    var userManager = UserManager()
    
    
    func getUserData(email: String) async throws{
        
        if let users = try? await userManager.getUsers() {
            if let user = users.first(where: { $0.email == email }) {
                DispatchQueue.main.async {
                    self.user = user
                }
            } else {
                throw PassError.emailError
            }
        } else {
            throw PassError.networkError
        }
        
        
        
        
    }
    
}
