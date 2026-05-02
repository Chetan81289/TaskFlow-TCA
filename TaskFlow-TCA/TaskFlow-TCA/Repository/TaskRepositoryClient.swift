//
//  TaskRepositoryClient.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import ComposableArchitecture
import Foundation

struct TaskRepositoryClient {
    var fetchTasks: @Sendable () async throws -> [TaskItem]
    var addTask: @Sendable (TaskItem) async throws -> Void
    var updateTask: @Sendable (TaskItem) async throws -> Void
    var deleteTask: @Sendable (UUID) async throws -> Void
}

extension TaskRepositoryClient: DependencyKey {
    static let liveValue = TaskRepositoryClient(
        fetchTasks: {
            try await CoreDataTaskRepository().fetchTasks()
        },
        addTask: { task in
            try await CoreDataTaskRepository().addTask(task)
        },
        updateTask: { task in
            try await CoreDataTaskRepository().updateTask(task)
        },
        deleteTask: { id in
            try await CoreDataTaskRepository().deleteTask(id: id)
        }
    )
}

extension DependencyValues {
    var taskRepository: TaskRepositoryClient {
        get { self[TaskRepositoryClient.self] }
        set { self[TaskRepositoryClient.self] = newValue }
    }
}
