//
//  LoginMV.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/1/24.
//

import Foundation

protocol LoginMV: ObservableObject {
    var user: String {get set}
    var pass: String {get set}
    var auth: Bool {get set}
    
    var saveAction: (Bool)->Void {get set}
    
    func login(ready: @escaping() -> Void)
    func isAuth() -> Bool
}

class LoginModelViewVM: LoginMV, ObservableObject  {

    @Published var user: String = ""
    @Published var pass: String = ""
    @Published var auth: Bool = false
    @Published var token: String = ""
    @Published var id: String = ""
    
    var saveAction: (Bool)->Void = { valid in
    }
    
    var saveAction2: (Bool)->Void = { valid in
    }
    
    init(user: String = "", password: String = "") {
        self.user = user
        self.pass = password
    }
    func login(ready: @escaping() -> Void) {
        LoginAction(
            parameters: LoginFetch(
                email: user,
                password: pass
            )
        ).sendRequest { data in
            
            //print("..0..0..0..0..0..:\n")
            //print(data)
            //print("..0..0..0..0..0..:\n")
            DispatchQueue.main.async{
               
                if let myUser = data.user {
                    self.user = myUser.email
                    self.auth = true
                    self.token = data.token!
                    self.id = myUser._id
                    
                    
                }else{
                    self.user = ""
                    self.auth = false
                    self.token = ""
                }
            }
            
            
           
            
          
            //print("user", self.user)
            //print (data)
            //print ("save all")
            
            //print(self.token != "")
            self.saveAction(self.token != "")
            ready()
            // Login successful, navigate to the Home screen
        }
    }
    
    func isAuth() -> Bool{
        return auth;
    }
}
