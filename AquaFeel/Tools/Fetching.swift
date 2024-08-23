//
//  Fetching.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/6/24.
//

import Foundation

enum LeadAllQuery: String, CaseIterable {
    case field
    case fromDate
    case toDate
    case statusId = "status_id"
    case limit
    case offset
    case searchKey = "search_key"
    case searchValue = "search_value"
    case quickDate
    case id
    case userId = "user_id"
    case today
    case lastMonth = "last_month"
    case ownerId = "owner_id"
    case leadId
    case favorite
}

protocol NeedStatusCode {
    var statusCode: Int? { get set }
}

enum APIError: Error {
    case networkError
    case authenticationError
    case userDataError
    case urlError
    case requestError
}

struct ApiConfig {
    var scheme: String
    let method: String
    let host: String
    let path: String
    let token: String
    let params: [String: String?]?
    var port: String? = nil
}

func _fetching<T: Decodable>(body: Data?, config: ApiConfig) async throws -> T {
    // URL of the API endpoint for updates
    print("config.scheme ... ", config.scheme)
    var components = URLComponents()
    components.scheme = config.scheme
    components.host = config.host
    components.path = config.path
    if let port = config.port {
        components.port = Int(port)
    }
    
    if let params = config.params {
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    guard let url = components.url else {
        throw APIError.urlError
    }
    
    // Create URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = config.method
    
    if let body = body {
        request.httpBody = body
    }
    
    // Add the authorization header with the Bearer token
    request.addValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    print("Url begin: \(url)\n")
    let (data, response) = try await URLSession.shared.data(for: request)
    
    //print(String(decoding: data, as: UTF8.self))
    print("Url end: \(url)\n")
    let decoder = JSONDecoder()
    
    let object = try decoder.decode(T.self, from: data)
    
    if var myProtocolObject = object as? NeedStatusCode {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestError
        }
        myProtocolObject.statusCode = httpResponse.statusCode
        return myProtocolObject as! T
    }
    
    /*
     let (data, response) = try await URLSession.shared.data(for: request)
     print(response)
     guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
     throw APIError.authenticationError
     }
     */
    // let decoder = JSONDecoder()
    return object // try decoder.decode(T.self, from: data)
}

func fetching<T: Decodable>(config: ApiConfig) async throws -> T {
    // URL of the API endpoint for updates
    
    do {
        return try await _fetching(body: nil, config: config)
        
    } catch {
        throw error
    }
}

func fetching<T2: Codable, T: Decodable>(body: T2, config: ApiConfig) async throws -> T {
    // URL of the API endpoint for updates
    
    do {
        let jsonData = try JSONEncoder().encode(body)
        /*
         if let jsonString = String(data: jsonData, encoding: .utf8) {
         print(jsonString)
         }
         */
        // let httpBody = jsonData
        return try await _fetching(body: jsonData, config: config)
        
    } catch {
        print(error)
        throw error
    }
    
    /*
     var components = URLComponents()
     components.scheme = "https"
     components.host = config.host
     components.path = config.path
     
     if let params = config.params {
     components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
     }
     
     guard let url = components.url else {
     throw APIError.urlError
     }
     
     // Create URLRequest
     var request = URLRequest(url: url)
     request.httpMethod = config.method
     
     // Set the request body with model data
     do {
     let jsonData = try JSONEncoder().encode(body)
     if let jsonString = String(data: jsonData, encoding: .utf8) {
     print(jsonString)
     }
     request.httpBody = jsonData
     
     } catch {
     throw APIError.requestError
     }
     
     // Add the authorization header with the Bearer token
     request.addValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
     let (data, _) = try await URLSession.shared.data(for: request)
     
     /*
      let (data, response) = try await URLSession.shared.data(for: request)
      print(response)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw APIError.authenticationError
      }
      */
     let decoder = JSONDecoder()
     return try decoder.decode(T.self, from: data)
     */
}


class LeadQuery {
    private var map: [String: String?] = [:]
    
    func add(_ key: LeadAllQuery, _ value: String) -> LeadQuery {
        // print(key.rawValue)
        map[key.rawValue] = value
        return self
    }
    
    func getQuery() -> [URLQueryItem] {
        return map.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    func get() -> [String: String?] {
        map
    }
}

