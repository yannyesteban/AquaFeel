//
//  LoginViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation

class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    func login() {
        LoginAction(
            parameters: LoginFetch(
                email: email,
                password: password
            )
        ).sendRequest { data in
            print("Ok")
           
            // Login successful, navigate to the Home screen
        }
    }
}
