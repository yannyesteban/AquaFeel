//
//  AppointmentWidgetBundle.swift
//  AppointmentWidget
//
//  Created by Yanny Esteban on 12/6/24.
//

import WidgetKit
import SwiftUI

@main
struct AppointmentWidgetBundle: WidgetBundle {
    var body: some Widget {
        AppointmentWidget()
        AppointmentWidgetLiveActivity()
    }
}
