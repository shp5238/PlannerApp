//
//  MainTabView.swift
//  
//
//  Created by Shreya Pasupuleti on 4/18/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            TodoListView()
                .tabItem {
                    Label("To-Do", systemImage: "checkmark.circle")
                }

            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
        }
    }
}
