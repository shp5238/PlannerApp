//
//  TodoListView.swift
//  
//
//  Created by Shreya Pasupuleti on 4/18/25.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

struct TodoListView: View {
    @State private var items: [TodoItem] = []
    @State private var newTask: String = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        guard !newTask.isEmpty else { return }
                        items.append(TodoItem(title: newTask, isDone: false))
                        newTask = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()

                List {
                    ForEach(items.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: items[index].isDone ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    items[index].isDone.toggle()
                                }
                            Text(items[index].title)
                                .strikethrough(items[index].isDone)
                        }
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("To-Do List")
        }
    }
}
