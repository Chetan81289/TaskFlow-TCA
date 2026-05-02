//
//  TaskListView.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import ComposableArchitecture
import SwiftUI

struct TaskListView: View {
    let store: StoreOf<TaskListFeature>
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            // We'll observe only the filteredTasks for the list content,
            // but we need a separate viewStore for filter/search bindings.
            WithViewStore(store, observe: { $0 }) { fullStore in
                VStack(spacing: 0) {
                    // Filter picker – create a binding via send
                    Picker("Filter", selection: Binding(
                        get: { fullStore.filterStatus },
                        set: { newStatus in
                            fullStore.send(.binding(.set(\.filterStatus, newStatus)))
                        }
                    )) {
                        Text("All").tag(TaskItem.TaskStatus?.none)
                        ForEach(TaskItem.TaskStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(TaskItem.TaskStatus?.some(status))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if fullStore.filteredTasks.isEmpty {
                        ContentUnavailableView.search(text: fullStore.searchText)
                    } else {
                        List {
                            ForEach(fullStore.filteredTasks) { task in
                                TaskRowView(task: task)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            fullStore.send(.deleteTask(task.id))
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        let next: TaskItem.TaskStatus = switch task.status {
                                        case .todo: .inProgress
                                        case .inProgress: .done
                                        case .done: .todo
                                        }
                                        var updated = task
                                        updated.status = next
                                        fullStore.send(.updateTask(updated))
                                    }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("TaskFlow")
                // Searchable using a binding
                .searchable(
                    text: Binding(
                        get: { fullStore.searchText },
                        set: { newText in
                            fullStore.send(.binding(.set(\.searchText, newText)))
                        }
                    ),
                    prompt: "Search tasks"
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddEditTaskView { newTask in
                        fullStore.send(.addTask(newTask))
                    }
                }
            }
        }
        .task {
            store.send(.loadTasks)
        }
    }
}
