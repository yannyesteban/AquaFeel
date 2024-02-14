//
//  PathOptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 6/2/24.
//

import SwiftUI
import GoogleMaps
import GoogleMapsUtils

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
    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    @State private var groupedLeads: [String: Int] = [:] // Propiedad para almacenar los resultados
    @Binding var path:GMSMutablePath

    //@Binding var aqua:AquaFeelApp

    
    var body: some View {
        
       
        
        VStack (alignment: .center){
            Text("Lasso Options ................ \(path.count())" )
            
            
            
            if !lead2.leads.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (alignment: .center) {
                        ForEach(Array(groupedLeads.keys), id: \.self) { statusName in
                            let count = groupedLeads[statusName] ?? 0
                            
                            VStack{
                                
                                SuperIconViewViewWrapper(status: getStatusType(from: statusName))
                                    .frame(width: 30, height: 30)
                                Text("\(count)")
                                
                            }
                            .padding(5)
                            
                        }
                    }
                }
                .padding(20)
            } else {
                Text("No hay datos disponibles")
            }
            
            HStack {
                Button(action: {
                    // Acción del primer botón
                }) {
                    VStack {
                        Image(systemName: "app.connected.to.app.below.fill") // Símbolo del primer botón
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Route") // Texto debajo del primer botón
                    }
                }
                .buttonStyle(BorderButtonStyle())
                
                
                Button(action: {
                    // Acción del segundo botón
                }) {
                    VStack {
                        Image(systemName: "person.fill.checkmark") // Símbolo del segundo botón
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Owner") // Texto debajo del segundo botón
                    }
                }
                .buttonStyle(BorderButtonStyle())
                Button(action: {
                    // Acción del tercer botón
                }) {
                    VStack {
                        Image(systemName: "star.fill") // Símbolo del tercer botón
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Status") // Texto debajo del tercer botón
                    }
                }
                .buttonStyle(BorderButtonStyle())
                
                Button(action: {
                    // Acción del tercer botón
                }) {
                    VStack {
                        Image(systemName: "trash.fill") // Símbolo del tercer botón
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Delete") // Texto debajo del tercer botón
                    }
                }
                .buttonStyle(BorderButtonStyle())
            }
        }
        .onAppear{
            loadDataAndProcess()
            
        }
        .onReceive(lead2.$leads) { leads in
            let leads = leads//.prefix(20)
            print("new count")
            print(path.count())
            //let path = GMSMutablePath()
            var leadsInsidePath: [LeadModel] = []
            
            for leadModel in leads {
                if 
                    //let latitudeStr = leadModel.latitude,
                   //let longitudeStr = leadModel.longitude,
                   let latitude = Double(leadModel.latitude),
                   let longitude = Double(leadModel.longitude) {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    
                    
                    if path.contains(coordinate: coordinate, geodesic: true) {
                        print("si esta dentro a.")
                        leadsInsidePath.append(leadModel)
                    }else{
                        //print("NO esta afuera b.")
                    }
                }
            }
            //leadsInsidePath = leads
            groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
                counts[lead.status_id.name, default: 0] += 1
            }
        }
        .onTapGesture {
            
            
            
        }
        
        
    }
    
    private func loadDataAndProcess() {
        lead2.loadAll()
        let leads = lead2.leads.prefix(20)
        
        
        //let path = GMSMutablePath()
        var leadsInsidePath: [LeadModel] = []
        
        for leadModel in leads {
            if let latitude = Double(leadModel.latitude),
               let longitude = Double(leadModel.longitude) {
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                           
                
                if path.contains(coordinate: coordinate, geodesic: true) {
                    print("si esta dentro")
                    leadsInsidePath.append(leadModel)
                }
            }
        }
        
        
        groupedLeads = leadsInsidePath.reduce(into: [:]) { counts, lead in
            counts[lead.status_id.name, default: 0] += 1
        }
        
        // Imprimir los resultados
        for (statusName, count) in groupedLeads {
            print("Status: \(statusName), Count: \(count)")
        }
        
    }
    
}


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

/*
#Preview("yannye") {
    PathOptionView().onTapGesture {
        print("x")
    }
}
*/
