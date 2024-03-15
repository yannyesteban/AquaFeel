//
//  UnknowJson.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/3/24.
//

import SwiftUI

struct UnknowJson: View {
    let json: [String: Any] // Puedes cambiar Any a AnyObject según sea necesario
    
    init(json: [String: Any]){
        self.json = json
    }
    
    var body: some View {
        VStack {
            Text("Nombre: \(getValue(forKey: "nombre") as? String ?? "Desconocido")")
            Text("Edad: \(getValue(forKey: "edad") as? Int ?? 0)")
            
            if let direccion = getValue(forKey: "direccion") as? [String: Any] {
                Text("Calle: \(direccion["calle"] as? String ?? "Desconocido")")
                Text("Ciudad: \(direccion["ciudad"] as? String ?? "Desconocido")")
            }
        }
    }
    
    private func getValue(forKey key: String) -> Any? {
        return json[key]
    }
}
/*
struct UnknowJson_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(json: [
            "nombre": "Juan",
            "edad": 25,
            "direccion": [
                "calle": "Calle Principal",
                "ciudad": "Ciudad Ejemplo"
            ]
        ])
    }
}
*/
