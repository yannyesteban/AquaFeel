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


class LeadManager: ObservableObject {
    @Published var leadFilter = LeadFilter()

    @Published var userId: String = ""
    @Published var token: String = ""
    @Published var role: String = ""

    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE"

    @Published var leads: [LeadModel] = []
    @Published var history: [LeadModel] = []
    @Published var selected: LeadModel?
    @Published var lead: LeadModel = .init()
    @Published var textFilter = ""
    @Published var filter = LeadFilter2()

    @Published var lastResult: Int?

    @Published var statusList: [StatusId] = []
    @Published var users: [User] = []

    var page = 1
    // var offset = 3
    var limit = 20
    var maxLoads = 0
    var leadsTotal = 0
    var autoLoad = false
    var resetData = false

    private var onInit = false
    private var cancellables: Set<AnyCancellable> = []

    private var lastTask: URLSessionDataTask?
    

    /// private var cancellables: Set<AnyCancellable> = []

    init(autoLoad: Bool = false, limit: Int = 20, maxLoads: Int = 100) {
        
        
        self.autoLoad = autoLoad
        self.limit = limit
        self.maxLoads = maxLoads
        // Aquí suscribimos a los cambios de textFilter
        /* $textFilter
             .debounce(for: .seconds(0.2), scheduler: RunLoop.main) // opcional: debounce para esperar un tiempo después de la última edición
             .sink { [weak self] newValue in

                 // Aquí puedes realizar la lógica que deseas cada vez que textFilter cambie
                 self?.search()
             }
             .store(in: &cancellables)

         $filter
             .map { $0.textFilter }
             .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
             .sink { [weak self] newValue in
                 self?.search()
             }
             .store(in: &cancellables)
         */
        $leadFilter

            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("leadFilter: ", self?.leads.count ?? 0)
                if let ME = self {
                    if ME.onInit {
                        print("hello weak self 2.0")
                        ME.lastTask?.cancel()
                        ME.search()
                    }

                    ME.onInit = true
                }
            }
            .store(in: &cancellables)
        
        
    }

    func list(query: LeadQuery? = nil, completion: (() -> Void)? = nil) {
        let offset = (page - 1) * limit

        if offset > leadsTotal {
            print("error offset")
            return
        }

        let q: LeadQuery

        if let _query = query {
            q = _query
        } else {
            q = LeadQuery()
        }
        _ = q
            .add(.offset, String(offset))
            .add(.limit, String(limit))

        if filter.textFilter != "" {
            _ = q
                .add(.searchKey, "all")
                .add(.searchValue, filter.textFilter)
        }

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

        /*
         if !filter.status.isEmpty {
             _ = q
                 .add(.statusId, filter.status.joined(separator: ","))
         }

         if !filter.owner.isEmpty {
             _ = q
                 .add(.ownerId, filter.owner.joined(separator: ","))
         }

         if filter.quickDate != .allTime {
             _ = q
                 .add(.quickDate, filter.quickDate.rawValue)
                 .add(.field, filter.dateField.rawValue)
             if filter.quickDate == .custom {
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                 let fromDate = filter.fromDate
                 let toDate = filter.toDate

                 _ = q
                     .add(.fromDate, dateFormatter.string(from: fromDate))
                     .add(.toDate, dateFormatter.string(from: toDate))
             }
         }
          */
        var path = "/leads/get"

        if role == "MANAGER" || role == "ADMIN" {
            path = "/leads/list-all"
        } else {
            _ = q.add(.userId, userId)
        }
        
        
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        
        //let info = ApiConfig(method: "GET", host: APIValues.host, path: path, token: token, params: q.get(), port: APIValues.port)
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

    func reset() {
        
        page = 1
        resetData = true
        textFilter = ""
        // filter = LeadFilter2()
        // leadFilter = LeadFilter()
        // leads = []
    }

    func resetFilter() {
        
        page = 1
        resetData = true
        textFilter = ""
        // filter = LeadFilter2()
        leadFilter = LeadFilter()
        leads = []
    }

    func search() {
        
        page = 1
        resetData = true

        if autoLoad {
            runLoad()
        } else {
            list()
        }
    }

    func runLoad() {
        
        list(query: nil) {
            if self.leads.count < self.maxLoads {
                self.runLoad()
            }
        }
    }

    func load(count: Int) {
        
        maxLoads = count
        autoLoad = false
        runLoad()
    }

    func loadLeadsContinuously() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            while self.leads.count < self.maxLoads {
                self.list()
            }
        }
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

        
       
        let params: [String : String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)

       
        
        DispatchQueue.main.async {
            if let index = self.leads.firstIndex(where: { $0.id == body.id }) {
                self.leads[index] = body
                
            } else {
                print("not found")
            }
            
            
        }
        
        fetch<LeadModel, LeadUpdateResponse>(body: body, config: info) { (result: Result<LeadModel /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(lead):
                DispatchQueue.main.async {
                    if let index = self.leads.firstIndex(where: { $0.id == body.id }) {
                        self.leads[index] = body

                    } else {
                        print("not found")
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

        
        let params: [String : String?]? = query.get()
        let method = "DELETE"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: path, token: token, params: query.get())

        _ = fetch<LeadDeleteResponse>(config: info) { (result: Result<LeadDeleteResponse, Error>) in
            switch result {
            case let .success(lead):
                DispatchQueue.main.async {
                    // self.leads[index] = body
                    // print(lead)
                    if let index = self.leads.firstIndex(where: { $0.id == leadId }) {
                        self.leads.remove(at: index)

                    } else {
                        print("not found")
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
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/details", token: token, params: q.get())

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
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/details", token: token, params: q.get())
        
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
        let params: [String : String?]? = nil
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list-all-sellers", token: token, params: nil)
        
        do {
            let response: AllSellersResponse = try await fetching(config: info)
            
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    
                    self.users = response.users
                    
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
        let params: [String : String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list", token: token, params: query.get())

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
        let params: [String : String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: token, params: query.get())

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
                // prettyPrint(response.user)
                //let usersResponse = try await _userList()
                // prettyPrint(userData)
                DispatchQueue.main.async {
                    self.statusList = statusResponse.list
                    //self.users = usersResponse.users
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
            print("... error ...")
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
            markers.append(MarkerInfo(userData: lead, position: lead.position, image: getUIImage(name: lead.status_id.name), borderColor: UIColor.black, borderWidth:0.0))
        }
        return markers
    }
}
