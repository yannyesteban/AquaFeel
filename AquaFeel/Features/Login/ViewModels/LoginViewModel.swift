//
//  LoginViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation

class LoginViewModel: ObservableObject {

    @Published var email: String = "yanyesteban@gmail.com"
    @Published var password: String = "Acceso1024"

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
