//
//  LoginProtocol.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 10/3/24.
//

import Foundation


protocol LoginProtocol: ObservableObject {
    var user: String { get set }
    var pass: String { get set }
    var auth: Bool { get set }
    var begin: Bool { get set }
    var isLoading: Bool { get set }
    
    var saveAction: (Bool) -> Void { get set }
    func login(completion: @escaping (Bool, LoginFetch?) -> Void)
    
    func isAuth() -> Bool
}
