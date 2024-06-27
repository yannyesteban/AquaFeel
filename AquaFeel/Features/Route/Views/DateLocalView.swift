//
//  DateLocalView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI

struct DateLocalView: View {
    // The original date string
    let dateString: String
    var showTime = true
    
    // The formatted date
    var formattedDate: String {
        // Create a date formatter
        let dateFormatter = DateFormatter()
        
        // Set the format of the original string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        // Configure the time zone, if necessary
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Convert the string to a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Create a local date and time formatter
            let localDateFormatter = DateFormatter()
            
            // Configure the date and time style according to your preferences
            localDateFormatter.dateStyle = .medium
            if showTime {
                localDateFormatter.timeStyle = .medium
            }
            
            
            // Convert the date to a string in local format
            return localDateFormatter.string(from: date)
            
        } else {
            // If the date could not be converted, return an error message
            return "Failed to convert string to Date"
        }
    }
    
    // The body of the view
    var body: some View {
        // Display the formatted date
        Text(formattedDate)
    }
}
