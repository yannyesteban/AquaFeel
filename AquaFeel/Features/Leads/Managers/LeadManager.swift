//
//  LeadManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 25/2/24.
//

import Combine
import CoreLocation
import Foundation
import GoogleMaps

@MainActor
class LeadManager: ObservableObject {
    // MARK: - Published Properties

    /*@Published var leadFilter = LeadFilter() {
         didSet { handleFilterChange() }
     }*/

    @Published var leadFilter = LeadFilter()

    @Published var userId: String = ""
    @Published var token: String = ""
    @Published var role: String = ""

    @Published var leads: [LeadModel] = []
    @Published var newLeads: [LeadModel] = []
    @Published var history: [LeadModel] = []
    @Published var selected: LeadModel?
    @Published var lead: LeadModel = .init()
    @Published var textFilter = ""
    @Published var filter = LeadFilter2()

    @Published var lastResult: Int?

    @Published var statusList: [StatusId] = []
    @Published var users: [User] = []

    // MARK: - Pagination

    private(set) var page = 1
    private(set) var limit = 20
    private(set) var maxLoads = 0
    private(set) var leadsTotal = 0
    private var resetData = false
    public var autoLoad = false
    private var onInit = false
    private var cancellables: Set<AnyCancellable> = []

    private var lastTask: URLSessionDataTask?

    /// private var cancellables: Set<AnyCancellable> = []

    // MARK: - Private Properties

    private var currentTask: Task<Void, Never>?
    private var lastFilterChange = Date()
    private let minFilterDebounceTime: TimeInterval = 0.2

    @Published var leadsInsidePath: [LeadModel] = []
    @Published var selectedItems: Set<String> = []
    @Published var groupedLeads: [String: Int] = [:]
    @Published var filteredLeads: [LeadModel] = []
    @Published var selectedLeads: [LeadModel] = []
    @Published var updated = false

    @Published var bulkStatusLeads: [LeadModel] = []
    @Published var bulkDeleteLeads: [LeadModel] = []

    init(autoLoad: Bool = false, limit: Int = 20, maxLoads: Int = 100) {
        self.autoLoad = autoLoad
        self.limit = limit
        self.maxLoads = maxLoads

        if autoLoad {
            Task { await loadInitialData() }
        }

        $leadFilter

            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in

                /* if let ME = self {
                     if ME.onInit {
                         print("hello weak self 2.0")
                         ME.lastTask?.cancel()
                         ME.search()
                     }

                     ME.onInit = true
                 }
                  */
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    func loadInitialData() async {
        reset()
        await loadLeadsContinuously()
    }

    // MARK: - Filter Handling

    public func handleFilterChange() {
        let now = Date()
        guard now.timeIntervalSince(lastFilterChange) >= minFilterDebounceTime else { return }
        lastFilterChange = now

        currentTask?.cancel()
        currentTask = Task {
            await loadInitialData()
        }
    }

    private func buildQuery(with query: LeadQuery?, offset: Int) -> LeadQuery {
        let q = query ?? LeadQuery()
            .add(.offset, String(offset))
            .add(.limit, String(limit))

        if !filter.textFilter.isEmpty {
            _ = q
                .add(.searchKey, "all")
                .add(.searchValue, filter.textFilter)
        }

        if !leadFilter.selectedStatuses.isEmpty {
            _ = q.add(.statusId, leadFilter.selectedStatuses.map(\._id).joined(separator: ","))
        }

        if !leadFilter.selectedOwner.isEmpty {
            _ = q.add(.ownerId, leadFilter.selectedOwner.joined(separator: ","))
        }

        if leadFilter.dateFilters.selectedQuickDate != TimeOption.allTime.rawValue {
            _ = q
                .add(.quickDate, leadFilter.dateFilters.selectedQuickDate)
                .add(.field, leadFilter.dateFilters.selectedDateFilter)

            if leadFilter.dateFilters.selectedQuickDate == TimeOption.custom.rawValue {
                _ = q
                    .add(.fromDate, leadFilter.dateFilters.fromDate)
                    .add(.toDate, leadFilter.dateFilters.toDate)
            }
        }

        if role != "MANAGER" || role != "ADMIN" {
            _ = q.add(.userId, userId)
        }

        return q
    }

    // MARK: - Network Operations

    func loadLeadsContinuously() async {
        while !Task.isCancelled && leads.count < maxLoads {
         
            do {
                let hasMore = try await list()
        
                if !hasMore { break }
        
            } catch {
                print("maxLoads Error loading leads:", error)
                break
            }
        }
    }

    func list(query: LeadQuery? = nil) async throws -> Bool {
        let offset = (page - 1) * limit

        guard offset <= leadsTotal else { return false }

        let q = buildQuery(with: query, offset: offset)

        let path = role == "MANAGER" || role == "ADMIN" ? "/leads/list-all" : "/leads/get"
        lastResult = nil
        let config = ApiConfig(
            scheme: APIValues.scheme,
            method: "GET",
            host: APIValues.host,
            path: path,
            token: token,
            params: q.get(),
            port: APIValues.port)

        let response: LeadsRequest = try await fetching(config: config)

        if response.leads.isEmpty {
            leads = [] // IS ALWAYS?
            resetData = true
            leadsTotal = response.count ?? 0
            page = 1
            return false
        }
        if resetData {
            leads = response.leads
            resetData = false
        } else {
            leads += response.leads
        }

        leadsTotal = response.count ?? 0
        page += 1
        lastResult = response.leads.count

        if autoLoad {
            maxLoads = response.count ?? 0
        }
        print("leads.count \(leads.count), maxLoads \(maxLoads) leadsTotal\(leadsTotal)")
        // return leads.count < min(leadsTotal, maxLoads)
        newLeads = response.leads
        return leads.count < leadsTotal
    }

    func reset() {
        page = 1
        resetData = true
        textFilter = ""
        leads = []
    }

    func resetFilter() {
        leadFilter = LeadFilter()
        reset()
    }

    func search() {
        /* page = 1
         resetData = true

         if autoLoad {
             runLoad()
         } else {
             list()
         }
          */
    }

    func runLoad() {
        /* list(query: nil) {
             print("self.maxLoads: ", self.maxLoads)
             if self.leads.count < self.maxLoads {
                 self.runLoad()
             }
         } */
    }

    func load(count: Int) {
        maxLoads = count
        autoLoad = false
        runLoad()
    }

    func save(body: LeadModel, mode: ModeSave = .edit, completion: @escaping (Bool, LeadModel?) -> Void) {
        var path: String

        switch mode {
        case .add:
            path = "/leads/add"
        case .edit:
            path = "/leads/edit"
        case .delete:
            path = "/leads/delete"
        case .none:
            return
        }

        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)

        DispatchQueue.main.async {
            if let index = self.leads.firstIndex(where: { $0.id == body.id }) {
                self.leads[index] = body

            } else {
                print("not found 1.0")
            }
        }

        fetch<LeadModel, LeadUpdateResponse>(body: body, config: info) { (result: Result<LeadModel /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(lead):
                DispatchQueue.main.async {
                    if let index = self.leads.firstIndex(where: { $0.id == body.id }) {
                        self.leads[index] = body

                    } else {
                        print("not found 1.1")
                    }

                    completion(true, lead)
                }
            case let .failure(error):
                OfflineStore.addLeads(lead: body, mode: mode)
                print("Error updating:", error)
                completion(false, nil)
            }
        }
    }

    func delete(query: LeadQuery, leadId: String, mode: ModeSave = .delete, completion: @escaping (Bool) -> Void) {
        let path: String = "/leads/delete"

        let params: [String: String?]? = query.get()
        let method = "DELETE"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: path, token: token, params: query.get())

        _ = fetch<LeadDeleteResponse>(config: info) { (result: Result<LeadDeleteResponse, Error>) in
            switch result {
            case let .success(lead):
                DispatchQueue.main.async {
                   
                    if let index = self.leads.firstIndex(where: { $0.id == leadId }) {
                        self.leads.remove(at: index)

                    } else {
                        print("not found 1.4")
                    }
                    completion(true)
                }
            case let .failure(error):
                print("Error updating:", error)
                completion(false)
            }
        }
    }

    func get(id: String) {
        let q = LeadQuery()
            .add(.id, id)

        let path = "/leads/details"
        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/details", token: token, params: q.get())

        _ = fetch(config: info) { (result: Result<LeadDetailRequest, Error>) in
            switch result {
            case let .success(data):

                DispatchQueue.main.async {
                    self.selected = data.lead
                }

            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }

    func getHistory(id: String) {
        let q = LeadQuery()
            .add(.id, id)

        let path = "/leads/details"
        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/details", token: token, params: q.get())

        _ = fetch(config: info) { (result: Result<LeadDetailRequest, Error>) in
            switch result {
            case let .success(data):

                DispatchQueue.main.async {
                    self.history = data.lead.history
                }

            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }

    func getSellers() async throws {
        let path = "/users/list-all-sellers"
        let params: [String: String?]? = nil
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list-all-sellers", token: token, params: nil)

        do {
            let response: AllSellersResponse = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.users = response.users
                    //print(self.users, "self.users")
                }
            } else {
                print("Error in list sellers")
            }

        } catch {
            throw error
        }
    }

    func _userList() async throws -> UsersRequest {
        let query = LeadQuery()

        _ = query
            .add(.offset, String("0"))
            .add(.limit, String("1000"))

        let path = "/users/list"
        let params: [String: String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list", token: token, params: query.get())

        do {
            let response: UsersRequest = try await fetching(config: info)

            return response

        } catch {
            throw error
        }
    }

    func _statusList() async throws -> StatusModel {
        let query = LeadQuery()

        let path = "/status/list"
        let params: [String: String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: token, params: query.get())

        do {
            let response: StatusModel = try await fetching(config: info)

            return response

        } catch {
            throw error
        }
    }

    func initFilter(completion: @escaping (Bool, LoginFetch?) -> Void) {
        Task {
            do {
                let statusResponse: StatusModel = try await _statusList()
                try? await getSellers()
                // prettyPrint(statusResponse)
                // let usersResponse = try await _userList()
                // prettyPrint(userData)
                DispatchQueue.main.async {
                    self.statusList = statusResponse.list
                    // self.users = usersResponse.users
                    completion(true, nil)
                }

            } catch {
                print("error 1.0 \(error)")
            }
        }
    }

    func newFromLocation(location: CLLocationCoordinate2D) async throws -> LeadModel {
        let detail = try await GoogleApis.getPlaceDetailsByCoordinates(location: location)

        var lead = LeadModel()
        lead.created_by = CreatorModel(_id: userId)
        lead.user_id = userId

        lead = decode(placeDetails: detail, lead: lead)

        return lead
    }

    func decode(placeDetails: PlaceDetails?, lead: LeadModel) -> LeadModel {
        var leadAddress = lead

        if let placeDetails = placeDetails {
            leadAddress.street_address = placeDetails.formatted_address ?? ""
            leadAddress.latitude = String(placeDetails.geometry?.location?.lat ?? 0.0)
            leadAddress.longitude = String(placeDetails.geometry?.location?.lng ?? 0.0)

            for component in placeDetails.address_components ?? [] {
                if component.types.contains("country") && component.types.contains("political") {
                    leadAddress.country = component.long_name
                } else if component.types.contains("administrative_area_level_1") && component.types.contains("political") {
                    leadAddress.state = component.short_name
                } else if component.types.contains("administrative_area_level_2") && component.types.contains("political") {
                    leadAddress.city = component.short_name
                } else if component.types.contains("postal_code") {
                    leadAddress.zip = component.long_name
                } else if component.types.contains("street_number") {
                    // leadAddress.s = component.long_name
                }
            }

        } else {
        }

        return leadAddress
    }

    func createMark(lead: LeadModel) -> GMSMarker {
        let marker = GMSMarker()

        marker.position = lead.position
        marker.userData = lead
        marker.isTappable = true
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)

        marker.userData = lead
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let circleIconView = getUIImage(name: lead.status_id.name)
        circleIconView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)

        customView.layer.borderColor = UIColor.blue.cgColor
        customView.layer.borderWidth = 0.0

        customView.addSubview(circleIconView)

        let circleLayer = CALayer()
        circleLayer.bounds = circleIconView.bounds
        circleLayer.position = CGPoint(x: circleIconView.bounds.midX + 5, y: circleIconView.bounds.midY + 5)
        circleLayer.cornerRadius = circleIconView.bounds.width / 2
        circleLayer.borderWidth = 0.0
        circleLayer.borderColor = UIColor.orange.cgColor

        customView.layer.addSublayer(circleLayer)

        marker.iconView = customView

        /*
         let circleIconView = getUIImage(name: lead.status_id.name)
         circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)

         let circleLayer = CALayer()
         circleLayer.bounds = circleIconView.bounds
         circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
         circleLayer.cornerRadius = circleIconView.bounds.width / 2
         circleLayer.borderWidth = 0.0
         circleLayer.borderColor = UIColor.black.cgColor

         circleIconView.layer.addSublayer(circleLayer)

         marker.iconView = circleIconView

         */
        return marker
    }

    func getMarkers() -> [GMSMarker] {
        var markers: [GMSMarker] = []
        for lead in leads {
            markers.append(createMark(lead: lead))
        }
        return markers
    }

    func getMarkers2() -> [MarkerInfo] {
        var markers: [MarkerInfo] = []
        for lead in leads {
            markers.append(MarkerInfo(userData: lead, position: lead.position, image: getUIImage(name: lead.status_id.name), borderColor: UIColor.black, borderWidth: 0.0))
        }
        return markers
    }

    func doExport(leadFilter: LeadFilter, completion: (() -> Void)? = nil) {
        let offset = (page - 1) * limit

        if offset > leadsTotal {
            return
        }

        let q: LeadQuery = LeadQuery()

        _ = q
            .add(.offset, String(offset))
            .add(.limit, String(limit))

        if !leadFilter.selectedStatuses.isEmpty {
            _ = q
                .add(.statusId, leadFilter.selectedStatuses.map { $0._id }.joined(separator: ","))
        }
        if !leadFilter.selectedOwner.isEmpty {
            _ = q
                .add(.ownerId, leadFilter.selectedOwner.joined(separator: ","))
        }
        if leadFilter.dateFilters.selectedQuickDate != TimeOption.allTime.rawValue {
            _ = q
                .add(.quickDate, leadFilter.dateFilters.selectedQuickDate)
                .add(.field, leadFilter.dateFilters.selectedDateFilter)
            if leadFilter.dateFilters.selectedQuickDate == TimeOption.custom.rawValue {
                _ = q
                    .add(.fromDate, leadFilter.dateFilters.fromDate)
                    .add(.toDate, leadFilter.dateFilters.toDate)
            }
        }

        let path = "/leads/export"

        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: APIValues.host, path: path, token: token, params: q.get(), port: APIValues.port)
        lastResult = nil
        lastTask = fetch(config: info) { (result: Result<LeadsRequest, Error>) in
            switch result {
            case let .success(data):

                DispatchQueue.main.async {
                    if data.leads.count > 0 {
                        if self.resetData {
                            self.leads = data.leads
                            self.resetData = false
                        } else {
                            self.leads += data.leads
                        }

                        if self.autoLoad {
                            self.maxLoads = data.count ?? 0
                        }
                        //
                        self.leadsTotal = data.count ?? 0
                        self.page += 1
                        completion?()
                    } else {
                        self.leads = []
                        self.resetData = true
                        self.leadsTotal = data.count ?? 0
                        self.page = 1
                    }

                    self.lastResult = data.leads.count
                }

            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }

    func bulkAssignToSeller(owner: CreatorModel) async throws {
        // DispatchQueue.main.async {
        // waiting = true
        // updated = false
        // }

        let leadsSelected = filteredLeads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkSeller(created_by: owner._id, ids: ids)

        let path = "/leads/bulk-assign-seller"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-assign-seller", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)

            // waiting = false
            DispatchQueue.main.async {
                if response.statusCode == 200 {
                    self.updated = true
                    
                    let selectedIds = self.filteredLeads.filter { $0.isSelected }.map { $0.id }
                    
                    // Actualizar cada lead afectado
                    for id in selectedIds {
                        if let index = self.leads.firstIndex(where: { $0.id == id }) {
                            self.leads[index].created_by = owner
                        }
                        if let index = self.filteredLeads.firstIndex(where: { $0.id == id }) {
                            self.filteredLeads[index].created_by = owner
                        }
                        if let index = self.leadsInsidePath.firstIndex(where: { $0.id == id }) {
                            self.leadsInsidePath[index].created_by = owner
                        }
                    }
                    self.bulkStatusLeads = self.filteredLeads
                }
            }

        } catch {
            // waiting = false
            throw error
        }
    }

    func bulkStatusUpdate(statusId: StatusId) async throws {
        // waiting = true
        updated = false
        let leadsSelected = filteredLeads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkStatus(status_id: statusId._id, ids: ids)

        let path = "/leads/bulk-status-update"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-status-update", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            DispatchQueue.main.async {
                // self.waiting = false
                if response.statusCode == 200 {
                    self.updated = true

                    let selectedIds = self.filteredLeads.filter { $0.isSelected }.map { $0.id }

                    // Actualizar cada lead afectado
                    for id in selectedIds {
                        if let index = self.leads.firstIndex(where: { $0.id == id }) {
                            self.leads[index].status_id = statusId
                        }
                        if let index = self.filteredLeads.firstIndex(where: { $0.id == id }) {
                            self.filteredLeads[index].status_id = statusId
                        }
                        if let index = self.leadsInsidePath.firstIndex(where: { $0.id == id }) {
                            self.leadsInsidePath[index].status_id = statusId
                        }
                    }
                    self.bulkStatusLeads = self.filteredLeads
                }
            }

        } catch {
            // waiting = false
            throw error
        }
    }

    func deleteBulk() async throws {
        // waiting = true
        // updated = false

        let leadsSelected = filteredLeads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkDelete(leadIds: ids)

        let path = "/leads/delete-bulk"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/delete-bulk", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            
            DispatchQueue.main.async {
                guard response.statusCode == 200 else { return }

                // Actualización optimizada de datos
                self.leads.removeAll { ids.contains($0.id) }
                self.filteredLeads.removeAll { ids.contains($0.id) }
                self.leadsInsidePath.removeAll { ids.contains($0.id) }
                
                // Actualización de selecciones
                self.selectedItems.subtract(ids)
                //selectedLeads.removeAll { ids.contains($0.id) }

                // Notificar cambios
                self.updated = true
                self.bulkDeleteLeads = leadsSelected
                
            }
           


        } catch {
            // waiting = false
            throw error
        }
    }

    func doLeadsInsidePath(path: GMSMutablePath) {
        var temp: [LeadModel] = []
        var tempSet: Set<String> = []
        for leadModel in leads {
            if
                // let latitudeStr = leadModel.latitude,
                // let longitudeStr = leadModel.longitude,
                let latitude = Double(leadModel.latitude),
                let longitude = Double(leadModel.longitude) {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                if path.contains(coordinate: coordinate, geodesic: false) {
                    // leadsInsidePath.append(leadModel)
                    temp.append(leadModel)
                    // selectedItems.insert(leadModel.status_id.name)
                    tempSet.insert(leadModel.status_id.name)
                    // selectedItems.insert(leadModel.status_id.name)
                }
            }
        }

        // DispatchQueue.main.async {
        leadsInsidePath = temp
        selectedItems = tempSet
        // }
    }
}
