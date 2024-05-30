//
//  ResourceManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/5/24.
//

import Foundation

class ResourceManager: ObservableObject {
    @Published var userId: String = ""
    @Published var resources: [ResourceModel] = []
    @Published var resource: ResourceModel?

    @Published var token: String = ""

    func list() async throws {
        print("yanny esteban 1.0")

        let q = LeadQuery()
            .add(.userId, userId)

        let path = "/resources/list"
        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: ResourcesResponse = try await fetching(config: info)

            DispatchQueue.main.async {
                self.resources = response.list
            }

        } catch {
            throw error
        }
    }

    func save(mode: RecordMode) async throws {
        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/resources/add"
        case .edit:
            path = "/resources/edit"
        case .delete:
            path = "/resources/delete"
            method = "DELETE"
        default:

            return
        }

        let params: [String: String?]? = nil

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: ResourceResponse = try await fetching(body: resource, config: info)
            DispatchQueue.main.async {
                // routes = response.routes
                if let resource = response.resource {
                    self.resource = resource
                }
            }

        } catch {
            throw error
        }
    }

    func uploadResource(resource: ResourceModel, fileURL: URL, mode: RecordMode = .new, completion: @escaping (Result<ResourceModel, Error>) -> Void) {
        let path: String
        switch mode {
        case .new:
            path = "\(APIValues.scheme)://\(APIValues.host):\(APIValues.port)/resources/add"
        default:
            path = "\(APIValues.scheme)://\(APIValues.host):\(APIValues.port)/resources/edit"
        }

        print(path, "path")
        guard let url = URL(string: path) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var data = Data()

        // Append id
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"_id\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(resource.id)\r\n".data(using: .utf8)!)

        // Append description
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(resource.description)\r\n".data(using: .utf8)!)

        // Append type
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(resource.type)\r\n".data(using: .utf8)!)

        print("resource.active ... ", resource.active)
        // Append active
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"active\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(resource.active)\r\n".data(using: .utf8)!)

        // Append createdBy
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"createdBy\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(resource.createdBy)\r\n".data(using: .utf8)!)

        // Append file data
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)

        do {
            let fileData = try Data(contentsOf: fileURL)
            data.append(fileData)
        } catch {
            print("Error reading file data: \(error)")
            return
        }

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in
            if let error = error {
                print("Error uploading resource: \(error)")
                completion(.failure(error))
                return
            }

            guard let responseData = responseData else {
                print("No data received in response")
                completion(.failure(NSError(domain: "", code: 20025, userInfo: [NSLocalizedDescriptionKey: "No data received in response"])))

                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ResourceResponse.self, from: responseData)
                if let resource = response.resource {
                    completion(.success(resource))
                } else {
                    completion(.failure(NSError(domain: "", code: 20026, userInfo: [NSLocalizedDescriptionKey: "no resource"])))
                }
            } catch {
                print("Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func delete(body: ResourceModel, completion: @escaping (Result<ResourceModel, Error>) -> Void) async {
        let path = "/resources/delete"

        let q = LeadQuery().add(.id, body.id)

        let params: [String: String?]? = q.get()
        let method = "DELETE"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        do {
            let response: ResourceResponse = try await fetching(body: body, config: info)

            if response.statusCode == 201 {
                completion(.success(response.resource ?? ResourceModel()))

            } else if response.statusCode == 400 {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
            }

        } catch {
            completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "API returned an error"])))
            // throw error
        }
    }
    
    func edit(body: ResourceModel, completion: @escaping (Result<ResourceModel, Error>) -> Void) async {
        let path = "/resources/editdata"
        
        let q = LeadQuery().add(.id, body.id)
        
        let params: [String: String?]? = q.get()
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        do {
            let response: ResourceResponse = try await fetching(body: body, config: info)
            
            if response.statusCode == 201 {
                completion(.success(response.resource ?? ResourceModel()))
                
            } else if response.statusCode == 400 {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
            }
            
        } catch {
            completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "API returned an error"])))
            // throw error
        }
    }
}