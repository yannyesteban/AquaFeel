//
//  EquitableView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/2/24.
//

import SwiftUI

struct EQModel:  Equatable {
    
    var id: String = ""
    var business_name: String = ""
    var first_name: String = ""
    var last_name: String = ""
    var phone: String = ""
    var phone2: String = ""
    var email: String = ""
    var street_address: String = ""
    var apt: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var country: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var appointment_date: String = ""
    var appointment_time: String = ""
    var status_id: StatusId = StatusId()
    var created_by: CreatorModel = CreatorModel(_id: "")
    var note: String = ""
    var owned_by: String? = ""
    var user_id: String = ""
    
    
    
    var isSelected: Bool = false
    var mode: Int = 2
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case business_name
        case first_name
        case last_name
        case phone
        case phone2
        case email
        case street_address
        case apt
        case city
        case state
        case zip
        case country
        case longitude
        case latitude
        case appointment_date
        case appointment_time
        case status_id
        case note
        /*
         case owned_by
         case created_on
         case updated_on*/
        //case user_id = "created_by"
        case _id = "id"
        // case created_by = "user_id"
        case created_by
        case user_id
        case isSelected
        case owned_by
        
    }
    
    static func == (lhs: EQModel, rhs: EQModel) -> Bool {
        print("\n\n", lhs,":\n", rhs)
        // Implementa la lógica de comparación entre dos instancias de LeadModel
        // Devuelve true si son iguales, false en caso contrario
        // Por ejemplo, puedes comparar propiedades relevantes para determinar la igualdad
        return true//false || lhs.phone == rhs.first_name
        // Repite este patrón para todas las propiedades que desees comparar
    }
}
struct EquitableView: View {
    @State private var nombre: String = ""
    @State private var edad: String = ""
    @State private var email: String = ""
    @State private var eq = EQModel()
    @State var lead: LeadModel = LeadModel()
    
    
    @State private var isShowingSnackbar = false
    
    
    var body: some View {
        NavigationView {
            Form{
                
                Section {
                    
                    TextField("EQ First Name", text: $eq.first_name)
                    TextField("EQ phone", text: $eq.phone)
                    
                    TextField("First Name", text: $lead.first_name)
                    TextField("Last Name", text: $lead.last_name)
                    TextField("Phone Number", text: $lead.phone)
                    TextField("Alternative Number", text: $lead.phone2)
                    TextField("Email Number", text: $lead.email)
                    
                }
                
            }
            .navigationTitle("Formulario SwiftUI")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    /*Button{
                     //lead2.save(body: lead)
                     mode = 1
                     
                     let user = UserModel()
                     
                     let query = LeadQuery()
                     .add(.id,"AHXrBjRDi")
                     
                     user.get(query: query)
                     
                     } label : {
                     Label("new", systemImage: "plus")
                     .font(.title)
                     .foregroundColor(.blue)
                     }*/
                    
                    
                    if isShowingSnackbar {
                        
                        ProgressView("")
                        
                    }else{
                        Button{
                            print (eq)
                            print("SAVE.....", lead)
                            isShowingSnackbar = true
                            /*var saveMode = ModeSave.edit
                             if mode == 1 {
                             //lead.user_id = "AHXrBjRDi"
                             saveMode = .add
                             //manager.save2(body: lead, mode: .add)
                             
                             }
                             manager.save(body: lead, mode: saveMode){ (ok, newLead) in
                             
                             isShowingSnackbar = false
                             
                             if ok, let newLead = newLead {
                             
                             
                             lead = newLead
                             mode = 2
                             }
                             
                             }
                             onSave()
                             */
                            
                        } label : {
                            Label("Save", systemImage: "externaldrive.fill")
                                .font(.title3)
                        }
                    }
                    /*Button{
                     deleteConfirm = true
                     }label: {
                     Label("Eliminar", systemImage: "trash")
                     .font(.title)
                     .foregroundColor(.red)
                     }*/
                }
                
            }
        }
    }
    
    func enviarFormulario() {
        // Aquí puedes procesar los datos ingresados, por ejemplo, imprimirlos en la consola
        print("Nombre: \(nombre)")
        print("Edad: \(edad)")
        print("Email: \(email)")
    }
}

#Preview {
    EquitableView()
}
