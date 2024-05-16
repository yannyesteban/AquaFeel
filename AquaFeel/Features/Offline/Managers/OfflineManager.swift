//
//  OfflineManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 12/5/24.
//

import Foundation
import Network

struct OfflineData: Codable {
    let leads: [LeadModel]
}

class OfflineStore {
    static var leads: [LeadModel] = []
    static var isRunning = true
    static var taskInterval = 30 // seconds
    static let monitor = NWPathMonitor()
    static var mode = 2

    static func addLeads(lead: LeadModel, mode: ModeSave) {
        var newLead = lead
        newLead.pending = true
        newLead.updateMode = mode
        leads.append(newLead)
    }

    static func load() async {
        do {
            let store: OfflineData = try await loadFile(name: "Offline.data")
            leads = store.leads

            DispatchQueue.main.async {
            }

        } catch {
            print(error)
        }
    }

    static func save() async {
        do {
            let data = OfflineData(leads: leads)

            try await saveFile(userData: data, name: "Offline.data")
        } catch {
            print(error)
        }
    }

    static func start() async {
        if mode == 1 {
            monitor.pathUpdateHandler = { path in

                if path.status == .satisfied {
                    Task {
                        do {
                            try await Task.sleep(nanoseconds: UInt64(taskInterval * 1000000000))
                            try await saveProfile()
                        } catch {
                            print(error)
                        }
                    }

                } else {
                    print("NOT connected")
                }
            }

            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
        } else {
            isRunning = true

            while isRunning {
                do {
                    try await Task.sleep(nanoseconds: UInt64(taskInterval * 1000000000))
                    try await saveProfile()
                } catch {
                    print(error)
                }
            }
        }
    }

    static func saveProfile() async throws {
        for i in 0 ..< leads.count {
            let result = try? await save(body: leads[i], mode: leads[i].updateMode)

            leads[i].pending = result ?? false
        }

        leads.removeAll { $0.pending }
    }

    static func save(body: LeadModel, mode: ModeSave = .edit) async throws -> Bool {
        var path: String

        switch mode {
        case .add:
            path = "/leads/add"
        case .edit:
            path = "/leads/edit"
        case .delete:
            path = "/leads/delete"
        case .none:
            print("none")
            return false
        }

        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let _: LeadModel = try await fetching(body: body, config: info)

            return true
        } catch {
            print("error, no conected!")
        }

        return false
    }
}

class OfflineManager: ObservableObject {
    @Published var leads: [LeadModel] = []
    @Published var data: OfflineData?
    @Published var taskInterval = 30 // seconds
    @Published var isRunning = true

    init() {
        Task {
            await load()
            await scheduleSaveProfileTask()
        }
    }

    func load() async {
        do {
            let store: OfflineData = try await loadFile(name: "Offline.data")

            DispatchQueue.main.async {
                self.leads = store.leads
            }

        } catch {
            print(error)
        }
    }

    func save(leads: [LeadModel]) async {
        do {
            let data = OfflineData(leads: leads)

            try await saveFile(userData: data, name: "Offline.data")
        } catch {
            print(error)
        }
    }

    func saveProfile() async throws {
    }

    func scheduleSaveProfileTask() async {
        DispatchQueue.main.async {
            self.isRunning = true
        }

        while isRunning {
            do {
                try await Task.sleep(nanoseconds: UInt64(taskInterval * 1000000000))
                try await saveProfile()
            } catch {
                print(error)
            }
        }
    }

    func stopTask() {
        DispatchQueue.main.async {
            self.isRunning = false
        }
    }

    func togglePause() {
        isRunning.toggle()
    }
}
