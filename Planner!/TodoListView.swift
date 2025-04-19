//
//  TodoListView.swift
//  
//
//
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers // Add this import for UTType

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
    var description: String?
    var dueDate: Date?
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var newTask: String = ""
    @Published var newDescription: String = ""
    @Published var newDueDate: Date? = nil
    @Published var deletedItems: [TodoItem] = []

    func addItem() {
        guard !newTask.isEmpty else { return }
        let newItem = TodoItem(
            title: newTask,
            isDone: false,
            description: newDescription.isEmpty ? nil : newDescription,
            dueDate: newDueDate
        )
        items.append(newItem)
        newTask = ""
        newDescription = ""
        newDueDate = nil
    }

    func toggleCompletion(for index: Int) {
        items[index].isDone.toggle()
    }

    func removeItems(at offsets: IndexSet) {
        for index in offsets {
            deletedItems.append(items[index])
        }
        items.remove(atOffsets: offsets)
    }

    func removeItem(at index: Int) {
        deletedItems.append(items[index])
        items.remove(at: index)
    }

    func undoDeletion() {
        guard let lastDeleted = deletedItems.last else { return }
        items.append(lastDeleted)
        deletedItems.removeLast()
    }

    // Sort items with completed tasks at the bottom
    func sortedItems() -> [TodoItem] {
        return items.sorted { (item1, item2) in
            if item1.isDone == item2.isDone {
                return item1.title < item2.title
            }
            return !item1.isDone && item2.isDone
        }
    }
}

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    
    // Track the dragging item index
    @State private var draggingItemIndex: Int?

    var body: some View {
        NavigationView {
            VStack {
                // Task input area
                HStack {
                    TextField("New task", text: $viewModel.newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.addItem()
                        }
                    Button(action: {
                        viewModel.addItem()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                // Description input area
                TextField("Description (optional)", text: $viewModel.newDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Due Date input area
                DatePicker("Due Date (optional)", selection: Binding(
                            get: { viewModel.newDueDate ?? Date() },
                            set: { viewModel.newDueDate = $0 }
                        ), displayedComponents: .date)
                    .padding(.horizontal)

                List {
                    ForEach(viewModel.sortedItems().indices, id: \.self) { index in
                        let item = viewModel.sortedItems()[index]
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        viewModel.toggleCompletion(for: index)
                                    }
                                Text(item.title)
                                    .strikethrough(item.isDone)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    viewModel.removeItem(at: index)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                            }

                            // Editable Description
                            TextField("Description", text: Binding(
                                get: { item.description ?? "" },
                                set: { newDescription in
                                    viewModel.items[index].description = newDescription
                                }
                            ))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Editable Due Date
                            DatePicker("Due Date", selection: Binding(
                                get: { item.dueDate ?? Date() },
                                set: { newDueDate in
                                    viewModel.items[index].dueDate = newDueDate
                                }
                            ), displayedComponents: .date)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                        .onDrag {
                            // Set the index of the dragging item
                            self.draggingItemIndex = index
                            return NSItemProvider(object: item.id.uuidString as NSString)
                        }
                        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                            guard let itemProvider = providers.first else { return false }
                            itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                                // Ensure the item is a string, then convert it to UUID
                                if let idString = item as? String,
                                   let id = UUID(uuidString: idString),
                                   let sourceIndex = self.viewModel.items.firstIndex(where: { $0.id == id }),
                                   let targetIndex = self.draggingItemIndex {
                                    // Move the dragged item to the new index
                                    if sourceIndex != targetIndex {
                                        withAnimation {
                                            // Move the item in the array
                                            let movedItem = self.viewModel.items[sourceIndex]
                                            self.viewModel.items.remove(at: sourceIndex)
                                            self.viewModel.items.insert(movedItem, at: targetIndex)
                                        }
                                    }
                                }
                            }
                            return true
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.removeItems(at: indexSet)
                    }
                }
                .frame(maxWidth: .infinity) // Ensures List takes full width

                // Undo Button
                if !viewModel.deletedItems.isEmpty {
                    Button("Undo Deletion") {
                        viewModel.undoDeletion()
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("To-Do List")
            .padding(.top)
            .frame(maxWidth: .infinity) // Ensures VStack takes full width
        }
        .frame(maxWidth: .infinity) // Ensures the whole view stretches to full width
    }
}







/* side pomodoro
import Foundation
import SwiftUI
import Combine

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
    var description: String?
    var dueDate: Date?
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var newTask: String = ""
    @Published var newDescription: String = ""
    @Published var newDueDate: Date? = nil
    @Published var deletedItems: [TodoItem] = []

    func addItem() {
        guard !newTask.isEmpty else { return }
        let newItem = TodoItem(
            title: newTask,
            isDone: false,
            description: newDescription.isEmpty ? nil : newDescription,
            dueDate: newDueDate
        )
        items.append(newItem)
        newTask = ""
        newDescription = ""
        newDueDate = nil
    }

    func toggleCompletion(for index: Int) {
        items[index].isDone.toggle()
    }

    func removeItems(at offsets: IndexSet) {
        // Save deleted items for undo
        for index in offsets {
            deletedItems.append(items[index])
        }
        items.remove(atOffsets: offsets)
    }

    func removeItem(at index: Int) {
        // Save deleted item for undo
        deletedItems.append(items[index])
        items.remove(at: index)
    }

    func undoDeletion() {
        guard let lastDeleted = deletedItems.last else { return }
        items.append(lastDeleted)
        deletedItems.removeLast()
    }
}

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var isPomodoroActive = false
    @State private var remainingTime = 1500 // 25 minutes in seconds
    @State private var timerSubscription: Cancellable?

    var body: some View {
        NavigationView {
            VStack {
                // Task input area
                HStack {
                    TextField("New task", text: $viewModel.newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.addItem()
                        }
                    Button(action: {
                        viewModel.addItem()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                // Description input area
                TextField("Description (optional)", text: $viewModel.newDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Due Date input area
                DatePicker("Due Date (optional)", selection: Binding(
                            get: { viewModel.newDueDate ?? Date() },
                            set: { viewModel.newDueDate = $0 }
                        ), displayedComponents: .date)
                    .padding(.horizontal)

                // Task list
                List {
                    ForEach(viewModel.items) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                            viewModel.toggleCompletion(for: index)
                                        }
                                    }
                                Text(item.title)
                                    .strikethrough(item.isDone)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.removeItem(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                            }

                            // Editable Description
                            TextField("Description", text: Binding(
                                get: { item.description ?? "" },
                                set: { newDescription in
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.items[index].description = newDescription
                                    }
                                }
                            ))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Editable Due Date
                            DatePicker("Due Date", selection: Binding(
                                get: { item.dueDate ?? Date() },
                                set: { newDueDate in
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.items[index].dueDate = newDueDate
                                    }
                                }
                            ), displayedComponents: .date)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        viewModel.removeItems(at: indexSet)
                    }
                }
                .frame(maxWidth: .infinity)

                // Undo Button
                if !viewModel.deletedItems.isEmpty {
                    Button("Undo Deletion") {
                        viewModel.undoDeletion()
                    }
                    .padding()
                    .foregroundColor(.blue)
                }

                // Pomodoro Timer
                Spacer()

                // Timer display
                Text("Time Remaining: \(formatTime(seconds: remainingTime))")
                    .font(.title)
                    .padding()

                // Timer Start/Stop button
                Button(action: {
                    if isPomodoroActive {
                        timerSubscription?.cancel()
                        isPomodoroActive = false
                    } else {
                        remainingTime = 1500 // Reset to 25 minutes
                        isPomodoroActive = true
                        // Start the timer
                        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                            .autoconnect()
                            .sink { _ in
                                if remainingTime > 0 {
                                    remainingTime -= 1
                                } else {
                                    isPomodoroActive = false
                                    timerSubscription?.cancel()
                                }
                            }
                    }
                }) {
                    Text(isPomodoroActive ? "Stop Pomodoro" : "Start Pomodoro")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(isPomodoroActive ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .navigationTitle("To-Do List")
            .padding(.top)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
*/







/*
// BASIC todo list deletion, enter for adding, description and due date
import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
    var description: String?
    var dueDate: Date?
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var newTask: String = ""
    @Published var newDescription: String = ""
    @Published var newDueDate: Date? = nil
    @Published var deletedItems: [TodoItem] = []

    func addItem() {
        guard !newTask.isEmpty else { return }
        let newItem = TodoItem(
            title: newTask,
            isDone: false,
            description: newDescription.isEmpty ? nil : newDescription,
            dueDate: newDueDate
        )
        items.append(newItem)
        newTask = ""
        newDescription = ""
        newDueDate = nil
    }

    func toggleCompletion(for index: Int) {
        items[index].isDone.toggle()
    }

    func removeItems(at offsets: IndexSet) {
        for index in offsets {
            deletedItems.append(items[index])
        }
        items.remove(atOffsets: offsets)
    }

    func removeItem(at index: Int) {
        deletedItems.append(items[index])
        items.remove(at: index)
    }

    func undoDeletion() {
        guard let lastDeleted = deletedItems.last else { return }
        items.append(lastDeleted)
        deletedItems.removeLast()
    }
}

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Task input area
                HStack {
                    TextField("New task", text: $viewModel.newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.addItem()
                        }
                    Button(action: {
                        viewModel.addItem()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                // Description input area
                TextField("Description (optional)", text: $viewModel.newDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Due Date input area
                DatePicker("Due Date (optional)", selection: Binding(
                            get: { viewModel.newDueDate ?? Date() },
                            set: { viewModel.newDueDate = $0 }
                        ), displayedComponents: .date)
                    .padding(.horizontal)

                List {
                    ForEach(viewModel.items) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                            viewModel.toggleCompletion(for: index)
                                        }
                                    }
                                Text(item.title)
                                    .strikethrough(item.isDone)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.removeItem(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                            }

                            // Editable Description
                            TextField("Description", text: Binding(
                                get: { item.description ?? "" },
                                set: { newDescription in
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.items[index].description = newDescription
                                    }
                                }
                            ))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Editable Due Date
                            DatePicker("Due Date", selection: Binding(
                                get: { item.dueDate ?? Date() },
                                set: { newDueDate in
                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.items[index].dueDate = newDueDate
                                    }
                                }
                            ), displayedComponents: .date)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        viewModel.removeItems(at: indexSet)
                    }
                }
                .frame(maxWidth: .infinity) // Ensures List takes full width

                // Undo Button
                if !viewModel.deletedItems.isEmpty {
                    Button("Undo Deletion") {
                        viewModel.undoDeletion()
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("To-Do List")
            .padding(.top)
            .frame(maxWidth: .infinity) // Ensures VStack takes full width
        }
        .frame(maxWidth: .infinity) // Ensures the whole view stretches to full width
    }
}
*/



/*
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
*/
