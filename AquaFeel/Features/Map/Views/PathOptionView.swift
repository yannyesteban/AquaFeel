//
//  PathOptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 6/2/24.
//

import SwiftUI
import GoogleMaps
import GoogleMapsUtils


struct NavigationButton: View {
    var imageName: String
    var label: String
    var badge: Int?
    var destination: () -> any View
    
    var body: some View {
        NavigationLink(destination: AnyView(destination())) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    
                Text(label)
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(1.0))
                .border(Color.gray, width: 1)
        )
        .foregroundColor(.gray)
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 0)
        )
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 3, y: 3)
        
        .overlay(
            badge.map { count in
               
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(Color.red))
                        .offset(x: 2, y: -14)
                
            }
            , alignment: .topTrailing)
    }
}

struct ButtonWithAction: View {
    var imageName: String
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text(label)
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(1.0))
                .border(Color.gray, width: 1)
        )
        .foregroundColor(.gray)
        .cornerRadius(0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 0)
        )
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 3, y: 3)
    }
}

struct BorderButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10) // Espaciado alrededor del botón
            .background(
                RoundedRectangle(cornerRadius: 5) // Aplica la forma del botón al fondo
                    .fill(Color.white.opacity(1.0)) // Fondo blanco
                    .border(Color.gray, width: 1) // Borde rojo con el mismo radio que el fondo
            )
            .foregroundColor(.gray) // Color del contenido del botón
            .cornerRadius(0) // Redondea las esquinas del contenido del botón
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 0) // Color y grosor del borde
            )
            .shadow(color: .gray.opacity(!configuration.isPressed ? 0.5 : 0), radius: 5, x: 3, y: 3)
            //.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}


struct PathOptionView: View {
    var profile:ProfileManager
    @StateObject var routeManager = RouteManager()
    //@StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    @State private var groupedLeads: [String: Int] = [:] // Propiedad para almacenar los resultados
    @Binding var leads: [LeadModel]
    @Binding var path: GMSMutablePath
    
    @State private var selectedItems: Set<String> = []
    @State var filteredLeads: [LeadModel] = []
    
    @State var leadsInsidePath: [LeadModel] = []
   
    var body: some View {
        NavigationStack{
            VStack (alignment: .center){
                Text("Lasso Options" )
                    .padding(.vertical, 20)
                /*Text(selectedItems.joined(separator: ", "))
                    .font(.body)
                    .padding()*/
                
                if !leadsInsidePath.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack (alignment: .center) {
                            Spacer()
                            ForEach(Array(groupedLeads.keys), id: \.self) { statusName in
                                let count = groupedLeads[statusName] ?? 0
                                
                                VStack{
                                    
                                    SuperIconViewViewWrapper(status: getStatusType(from: statusName))
                                        .frame(width: 30, height: 30)
                                    //.colorMultiply(Color.white)
                                    //.imageModifier(Color.gray)
                                    //.imageModifier(.grayscale(0.8))
                                        .grayscale(!selectedItems.contains(statusName) ? 0.9 : 0.0)
                                    //.brightness(selectedItems.contains(statusName) ? 0.5 : 5)
                                        .brightness(!selectedItems.contains(statusName) ? 0.3 : 0.0)
                                    if selectedItems.contains(statusName){
                                        Text("\(count)")
                                    }else{
                                        Text("0")
                                            .brightness(0.1)
                                    }
                                    //Text("\(count)")
                                    
                                }
                                .padding(5)
                                .onTapGesture {
                                    // Acción al hacer tap en el elemento
                                    toggleSelection(statusName)
                                    
                                    //print("Tapped on \(statusName)")
                                }
                                /*.overlay(
                                 RoundedRectangle(cornerRadius: 8)
                                 .stroke(selectedItems.contains(statusName) ? Color.blue : Color.gray, lineWidth: 2)
                                 )
                                 .background(
                                 RoundedRectangle(cornerRadius: 8)
                                 .fill(selectedItems.contains(statusName) ? Color.gray.opacity(0.2) : Color.clear)
                                 )*/
                                
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                } else {
                    Text("No Data")
                }
                
                HStack {
                    
                    NavigationButton(imageName: "app.connected.to.app.below.fill", label: "Route", badge: filteredLeads.count){
                        //RouteView01(leads: $filteredLeads)
                        RouteView(profile: profile, routeManager: routeManager, mode: .new, id: "0", leads: filteredLeads)
                    }
                    NavigationButton(imageName: "person.fill.checkmark", label: "Owner"){
                        Text("Owner")
                    }
                    
                    ButtonWithAction(imageName: "star.fill", label: "Status"){
                        //print("Status ....")
                        updateLeads()
                        
                        
                    }
                    
                    ButtonWithAction(imageName: "trash.fill", label: "Delete"){
                        print("Delete ....")
                        loadDataAndProcess()
                    }
                    
                    
                    /*
                    
                    List(filteredLeads, id: \.id) { lead in
                        Text(lead.status_id.name)
                        // print (lead.status_id.name)
                        // Tu contenido de vista para cada elemento
                    }
                    */
                }
                Text("Total Leads \(leads.count)")
            }
            .onAppear{
                
                /*
                 path.removeAllCoordinates()
                 
                 
                path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -125.0000000))
                path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -66.9345703))
                path.add(CLLocationCoordinate2D(latitude: 24.396308, longitude: -66.9345703))
                path.add(CLLocationCoordinate2D(latitude: 24.396308, longitude: -125.0000000))
                path.add(CLLocationCoordinate2D(latitude: 49.3457868, longitude: -125.0000000))
                
                // Otros puntos para mejorar la forma del path
                path.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                path.add(CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
                path.add(CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298))
                path.add(CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
                path.add(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                */
                
                leadsInsidePath = []
                loadDataAndProcess()
                
            }
            .onChange(of: leads.count) { newLeads in
                loadDataAndProcess()
            }
            .onChange(of: selectedItems){ _ in
                updateLeads()
                
            }
            
            
            /*.onReceive($leads) { leads in
                let leads = leads//.prefix(20)
                
                //let path = GMSMutablePath()
                
                print("start")
                
                for leadModel in leads {
                    if
                        //let latitudeStr = leadModel.latitude,
                        //let longitudeStr = leadModel.longitude,
                        let latitude = Double(leadModel.latitude),
                        let longitude = Double(leadModel.longitude) {
                        
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        
                        
                        if path.contains(coordinate: coordinate, geodesic: false) {
                            //print(".....si esta dentro a....")
                            leadsInsidePath.append(leadModel)
                            selectedItems.insert(leadModel.status_id.name)
                            //selectedItems.insert(leadModel.status_id.name)
                        }else{
                            //leadsInsidePath.append(leadModel)
                            //print("NO esta afuera b.")
                        }
                    }
                }
                print("End", leadsInsidePath.count)
                
                //leadsInsidePath = leads
                groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
                    counts[lead.status_id.name, default: 0] += 1
                }
                
                updateLeads()
            }
             
             */
            .onTapGesture {
                
                
                
            }
        }
        
        
        
    }
    func updateLeads(){
        
        filteredLeads = leadsInsidePath.filter { lead in
            selectedItems.contains(lead.status_id.name)
        }
        
    }
    func toggleSelection(_ statusName: String) {
        if selectedItems.contains(statusName) {
            selectedItems.remove(statusName)
        } else {
            selectedItems.insert(statusName)
        }
        
        updateLeads()
    }
    
    
    private func loadDataAndProcess() {
        
        
        
        //let first100Leads = leads.prefix(100)  // Filtra solo los primeros 100 registros
        print("begin calculations")
        
        var temp: [LeadModel] = []
        var tempSet : Set<String> = []
        for leadModel in leads {
            if
                //let latitudeStr = leadModel.latitude,
                //let longitudeStr = leadModel.longitude,
                let latitude = Double(leadModel.latitude),
                let longitude = Double(leadModel.longitude) {
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                
                
                if path.contains(coordinate: coordinate, geodesic: false) {
                   
                    //leadsInsidePath.append(leadModel)
                    temp.append(leadModel)
                    //selectedItems.insert(leadModel.status_id.name)
                    tempSet.insert(leadModel.status_id.name)
                    //selectedItems.insert(leadModel.status_id.name)
               
                }
            }
        }
        
        leadsInsidePath = temp
        selectedItems = tempSet
        
        print("end calculations")
        
        
        groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
            counts[lead.status_id.name, default: 0] += 1
        }
        
        // Imprimir los resultados
        /*for (statusName, count) in groupedLeads {
            print("Status: \(statusName), Count: \(count)")
        }
        */
        updateLeads()
        
    }
    
}
/*
#Preview {
    HomeScreen(option:"b")
}
*/
/*
struct GeoPreview2: PreviewProvider {
    static var previews: some View {
        XX()
    }
    
    struct XX: View {
        @State private var mode: Bool = true
        @State var showSettings = true
        //@State var path = GMSMutablePath()
        @StateObject var aqua = AquaFeelModel()
        var body: some View {
            PathOptionView(path: $aqua.path)
        }
    }
}
*/
/*
#Preview("yannye") {
    PathOptionView().onTapGesture {
        print("x")
    }
}
*/
