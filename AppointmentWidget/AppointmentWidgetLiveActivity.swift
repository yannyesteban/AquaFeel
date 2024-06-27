//
//  AppointmentWidgetLiveActivity.swift
//  AppointmentWidget
//
//  Created by Yanny Esteban on 12/6/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AppointmentWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AppointmentWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AppointmentWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AppointmentWidgetAttributes {
    fileprivate static var preview: AppointmentWidgetAttributes {
        AppointmentWidgetAttributes(name: "World")
    }
}

extension AppointmentWidgetAttributes.ContentState {
    fileprivate static var smiley: AppointmentWidgetAttributes.ContentState {
        AppointmentWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AppointmentWidgetAttributes.ContentState {
         AppointmentWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AppointmentWidgetAttributes.preview) {
   AppointmentWidgetLiveActivity()
} contentStates: {
    AppointmentWidgetAttributes.ContentState.smiley
    AppointmentWidgetAttributes.ContentState.starEyes
}
