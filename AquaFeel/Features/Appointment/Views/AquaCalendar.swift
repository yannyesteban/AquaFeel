//
//  AquaCalendar.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/3/24.
//

import SwiftUI
import UIKit

struct AquaCalendar: UIViewRepresentable {
    @Binding var selected: Date?
    @Binding var month: Date?
    @Binding var picked: Bool

    public var specialDates: [DateComponents] = [
        // DateComponents(year: 2024, month: 3, day: 18),
        // DateComponents(year: 2024, month: 3, day: 25),
        // ... add more as needed
    ]
    public var calendarIdentifier: Calendar.Identifier = .gregorian
    var changeDate: ((Date) -> Void)?
    var changeMonth: ((Date) -> Void)?

    private let view = UICalendarView()

    func makeCoordinator() -> Coord {
        Coord(month: $month, calendarIdentifier: calendarIdentifier, selectedDate: $selected, calendarView: view, picked: $picked)
    }

    func makeUIView(context: Context) -> UICalendarView {
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        view.calendar = Calendar(identifier: calendarIdentifier)

        let calendarSelection = UICalendarSelectionMultiDate(delegate: context.coordinator as UICalendarSelectionMultiDateDelegate)
        calendarSelection.setSelectedDates(specialDates, animated: true)
        view.selectionBehavior = calendarSelection

        context.coordinator.selectedDates = specialDates
        context.coordinator.changeDate = changeDate
        context.coordinator.changeMonth = changeMonth

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        if let calendarSelection = uiView.selectionBehavior as? UICalendarSelectionMultiDate {
            calendarSelection.setSelectedDates(specialDates, animated: true)
        }

        let calendar = Calendar(identifier: calendarIdentifier)
        uiView.calendar = calendar

        context.coordinator.selectedDates = specialDates
        context.coordinator.calendarIdentifier = calendarIdentifier
    }

    class Coord: NSObject, UICalendarSelectionMultiDateDelegate, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
        var month: Binding<Date?>
        var picked: Binding<Bool>

        var selectedDates: [DateComponents] = [
            // DateComponents(year: 2024, month: 3, day: 24),
            // DateComponents(year: 2024, month: 3, day: 25),

            // ... add more as needed
        ]

        var changeDate: ((Date) -> Void)?
        var changeMonth: ((Date) -> Void)?
        var calendarIdentifier: Calendar.Identifier = .gregorian
        @Binding var selectedDate: Date?
        var pickedDate: Date?
        var calendar: Calendar {
            Calendar(identifier: calendarIdentifier)
        }

        let calendarView: UICalendarView

        init(month: Binding<Date?>, calendarIdentifier: Calendar.Identifier, selectedDate: Binding<Date?>, calendarView: UICalendarView, picked: Binding<Bool>) {
            self.month = month
            self.calendarIdentifier = calendarIdentifier
            _selectedDate = selectedDate
            self.calendarView = calendarView
            self.picked = picked
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            let calendar = Calendar.current

            if let date = calendar.date(from: dateComponents) {
                if date != selectedDate {
                    // selectedDate = date
                    DispatchQueue.main.async {
                        self.selectedDate = date
                    }
                }
            }

            DispatchQueue.main.async {
                self.picked.wrappedValue.toggle()

                selection.setSelectedDates(self.selectedDates, animated: true)
            }
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
            let calendar = Calendar.current

            if let date = calendar.date(from: DateComponents(year: calendarView.visibleDateComponents.year, month: calendarView.visibleDateComponents.month, day: 1)) {
                DispatchQueue.main.async {
                    if date != self.month.wrappedValue {
                        self.month.wrappedValue = date
                        self.changeMonth?(date)
                    }
                }
            }

            return true
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
            let calendar = Calendar.current

            if let date = calendar.date(from: dateComponents) {
                if date != selectedDate {
                    // selectedDate = date
                    DispatchQueue.main.async {
                        self.selectedDate = date
                    }
                }
            }
            picked.wrappedValue.toggle()
            return false
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents, let date = calendar.date(from: dateComponents) else { return }
            
            DispatchQueue.main.async {
                self.selectedDate = date
            }
        }

        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            return .default(color: .orange, size: .small)
        }
    }
}
