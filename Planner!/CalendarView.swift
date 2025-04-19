//
//  CalendarView.swift
//  
//
//  Created by Shreya Pasupuleti on 4/18/25.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()

            Text("Events on \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.headline)
                .padding()
        }
    }
}
