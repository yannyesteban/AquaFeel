//
//  TabB.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/1/24.
//

import SwiftUI

struct CC: View {
    @State private var showSettings = false
    
    
    var body: some View {
        Button("View Settings") {
            showSettings = true
        }
        .sheet(isPresented: $showSettings) {
            TabB()
                .presentationDetents([.fraction(0.30), .medium, .large])
                .presentationContentInteraction(.scrolls)
        }
    }
}


struct TabB: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
            Text("\(2)")
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .bold))
            
        }
        
        
    }
}


extension PresentationDetent {
    static let bar = Self.custom(BarDetent.self)
    static let small = Self.height(100)
    static let extraLarge = Self.fraction(0.75)
}


private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}


struct ContentView001: View {
    @State private var showSettings = false
    @State private var selectedDetent = PresentationDetent.bar
    
    
    var body: some View {
        Button("View Settings") {
            showSettings = true
        }
        .sheet(isPresented: $showSettings) {
            TabB()
                .presentationDetents(
                    [.bar, .small, .medium, .large, .extraLarge],
                    selection: $selectedDetent)
        }
    }
}


#Preview {
    ContentView001()
}



struct TestDatePicker: View {
    
    private static func weekOfYear(for date: Date) -> Double {
        Double(Calendar.current.component(.weekOfYear, from: date))
    }
    
    private static func weekDay(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: date)
        return weekDay
    }
    
    @State private var date: Date
    @State private var weekOfYear: Double
    @State private var weekDay: String
    @State private var lastWeekOfThisYear = 53.0
    
    private var dateProxy:Binding<Date> {
        Binding<Date>(get: {self.date }, set: {
            self.date = $0
            self.updateWeekAndDayFromDate()
        })
    }
    
    init() {
        let now = Date()
        self._date = State<Date>(initialValue: now)
        self._weekOfYear = State<Double>(initialValue: Self.weekOfYear(for: now))
        self._weekDay = State<String>(initialValue: Self.weekDay(for: now))
    }
    
    var body: some View {
        
        VStack {
            
            // Date Picker
            DatePicker(selection: $date, displayedComponents: .date, label:{ Text("Please enter a date") }
            )
            .labelsHidden()
            
            .datePickerStyle(.graphical)
            .onChange(of: date){ value in
               print(value)
            }
            //.datePickerStyle(WheelDatePickerStyle())
            
            // Week number and day
            Text("Week \(Int(weekOfYear.rounded()))")
            Text("\(weekDay)")
            
            // Slider
            Slider(value: $weekOfYear, in: 1...lastWeekOfThisYear, onEditingChanged: { _ in
                self.updateDateFromWeek()
            })
        }
        
    }
    
    func updateWeekAndDayFromDate() {
        self.weekOfYear = Self.weekOfYear(for: self.date)
        self.weekDay = Self.weekDay(for: self.date)
    }
    
    func updateDateFromWeek() {
        // To do
    }
    
    func setToday() {
        // To do
    }
    
    func getWeekDay(_ date: Date) -> String {
        ""
    }
}

struct TestDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        TestDatePicker()
    }
}
