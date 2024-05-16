//
//  LoginAction.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation
/*
struct LoginAction {
    
    var parameters: LoginFetch
    
    func sendRequest(completion: @escaping (LoginResponse) -> Void) {
        
        print("find here , there are a mistake ...")
        let scheme: String = "https"
        let host: String = "api.aquafeelvirginia.com"
        let path = "/auth/login"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        
        guard let url = components.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print(parameters)
        
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print("Unable to encode request parameters")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
                        
            if let data = data {
                
                let response = try? JSONDecoder().decode(LoginResponse.self, from: data)
                
                if let response = response {
                    
                    completion(response)
                } else {
                   
                    print("Unable to decode response JSON")
                    
                }
                
            } else {
                // Error: API request failed
               
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
*/

struct FetchAction<T:Decodable> {
    
    var parameters: LoginFetch
    
    func sendRequest(completion: @escaping (T) -> Void) {
        
        print("find here , there are a mistake 2...")
        let scheme: String = "https"
        let host: String = "api.aquafeelvirginia.com"
        let path = "/auth/login"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        guard let url = components.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print(parameters)
        
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print("Unable to encode request parameters")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                
                let response = try? JSONDecoder().decode(T.self, from: data)
                
                if let response = response {
                    print(response)
                    completion(response)
                } else {
                   
                    print("Unable to decode response JSON")
                    
                }
                
            } else {
                // Error: API request failed
               
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
