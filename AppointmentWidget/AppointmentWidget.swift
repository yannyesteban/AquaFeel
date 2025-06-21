//
//  AppointmentWidget.swift
//  AppointmentWidget
//
//  Created by Yanny Esteban on 12/6/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @ObservedObject var manager = WidgetManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), leads: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), leads: manager.leads)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            do {
                var userId = ""
                if let userDefaults = UserDefaults(suiteName: "group.aquafeelvirginia.com.AquaFeel") {
                    userId = userDefaults.string(forKey: "userId") ?? ""
                  
                }
                //userId = "DD2EMns3y"
                manager.userId = userId
                try await manager.list()
            } catch {
                print("Error fetching leads: \(error)")
            }
            
            var entries: [SimpleEntry] = []
            let currentDate = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
            
            /*
             let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
             let filteredLeads = manager.leads.filter { lead in
             
             
             let isoDateFormatter = ISO8601DateFormatter()
             isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
             
             guard let appointmentDate = isoDateFormatter.date(from: lead.appointment_date) else { return false }
             return appointmentDate >= entryDate
             }
             let entry = SimpleEntry(date: entryDate, leads: filteredLeads)
             
             // Crea una línea de tiempo con la entrada actual y la fecha de próxima actualización
             let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
             completion(timeline)
             
             */
            for hourOffset in 0 ..< 2 {
                /*let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                 let entry = SimpleEntry(date: entryDate, leads: manager.leads)
                 entries.append(entry)
                 */
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let filteredLeads = manager.leads.filter { lead in
                    
                    
                    let isoDateFormatter = ISO8601DateFormatter()
                    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    guard let appointmentDate = isoDateFormatter.date(from: lead.appointment_date) else { return false }
                    return appointmentDate >= entryDate
                }
                let entry = SimpleEntry(date: entryDate, leads: filteredLeads)
                entries.append(entry)
            }
            
            //let timeline = Timeline(entries: entries, policy: .atEnd)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
            
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let leads: [LeadModel]
}

struct CustomIconView: View {
    let iconInfo: IconInfo
    
    var body: some View {
        Image(systemName: iconInfo.imageName)
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .fill(iconInfo.color)
                    .frame(width: 30, height: 30)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 2, y: 2)
            )
    }
}

struct AppointmentWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .center) {
            if entry.leads.count <= 0 {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                       
                        Text("No appointment found!").font(.footnote)
                    }
                    .padding(.vertical, 5)
                    
                    // Add Divider between items
                   
                }
                Divider()
                Spacer()
            }
            ForEach(entry.leads.prefix(2), id: \.id) { lead in
                let iconInfo = getIconInfo3(status: getStatusType3(from: lead.status_id.name))
                
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        CustomIconView(iconInfo: iconInfo)
                        Text(formattedTime(from: lead.appointment_time)).font(.footnote)
                    }
                    .frame(width: 70)
                    
                    VStack(alignment: .leading) {
                        Text("\(lead.first_name) \(lead.last_name)")
                            .font(.subheadline)
                        // .lineLimit(1)
                        
                        Text("\(lead.street_address)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        // .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                .padding(.vertical, 5)
                
                // Add Divider between items
                Divider()
                Spacer()
            }
        }
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AppointmentWidget: Widget {
    let kind: String = "AppointmentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AppointmentWidgetEntryView(entry: entry)
                    //.containerBackground(.fill.tertiary, for: .widget)
            } else {
                AppointmentWidgetEntryView(entry: entry)
                    //.padding()
                    //.background()
            }
        }
        .configurationDisplayName("Appointment Widget")
        .description("Widget to display Aquafeel leads.")
    }
}
/*
#Preview(as: .systemSmall) {
    AppointmentWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
*/
