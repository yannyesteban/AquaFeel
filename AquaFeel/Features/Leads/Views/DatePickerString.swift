//
//  DatePickerString.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/5/24.
//

import SwiftUI

struct DatePickerString: View {
    var title: String
    @Binding var text: String
    
    private var realDate: Date {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoDateFormatter.date(from: text) {
            return date
        } else {
            return Date()
        }
        
        /*
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
         //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
         
         if let date = dateFormatter.date(from: text) {
         return date
         } else {
         // If the conversion fails, returns the current date as the default value
         return Date()
         }
         */
    }
    
    var body: some View {
        DatePicker(
            title,
            selection: Binding<Date>(
                get: { self.realDate },
                set: { newValue in
                    // Convert the new selected date to a string format and assign to the ObservableLeadModel
                    /* let dateFormatter = DateFormatter()
                     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                     // dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                     
                     text = dateFormatter.string(from: newValue)
                     */
                    
                    let isoDateFormatter = ISO8601DateFormatter()
                    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    text = isoDateFormatter.string(from: newValue)
                }
            ),
            
            displayedComponents: [.date, .hourAndMinute]
        )
    }
}
