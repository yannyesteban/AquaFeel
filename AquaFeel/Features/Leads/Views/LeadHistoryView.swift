//
//  LeadHistoryView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 15/4/24.
//

import SwiftUI

struct LeadHistoryView: View {
    var profile: ProfileManager = ProfileManager()
    @StateObject var leadManager = LeadManager()
    @State private var isLoading = false
    @State private var isFinished = false

    @State var id = ""

    var body: some View {
        List {
            ForEach(leadManager.history, id: \.self) { lead in

                HStack {
                    SuperIconViewViewWrapper(status: getStatusType(from: lead.status_id.name))
                        .frame(width: 34, height: 34)
                    VStack(alignment: .leading) {
                        Text("\(lead.first_name) \(lead.last_name)")
                        // .fontWeight(.semibold)
                        // .foregroundStyle(.blue)

                        Text("\(lead.street_address)")
                            .foregroundStyle(.gray)
                        Text("\(lead.createdOn.formatted())")
                    }
                }
            }
            
            if leadManager.history.count == 0 {
                Text("no data found!")
            }

            
        }

        .onAppear {
            
            leadManager.userId = profile.userId
            leadManager.token = profile.token
            leadManager.role = profile.role
            
            leadManager.getHistory(id: id)
        }
    }
}

#Preview {
    LeadHistoryView()
}
