//
//  PrettyPrint.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/3/24.
//

import Foundation


func prettyPrint<T: Encodable>(_ object: T) {
    do {
        let jsonData = try JSONEncoder().encode(object)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            if let data = jsonString.data(using: .utf8) {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) {
                    print(prettyPrintedJson)
                }
            }
        }
    } catch {
        print("Error al pretty print el JSON: \(error)")
    }
}
