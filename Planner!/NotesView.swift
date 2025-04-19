//
//  NotesView.swift
//  
//
//  Created by Shreya Pasupuleti on 4/18/25.
//

import Foundation
import SwiftUI

struct NotesView: View {
    @AppStorage("notesText") private var notesText = ""

    var body: some View {
        NavigationView {
            TextEditor(text: $notesText)
                .padding()
                .navigationTitle("Notes")
        }
    }
}
