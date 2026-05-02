//
//  TaskListFeatureTests.swift
//  TaskFlowTCATests
//
//  Created by Jyoti Purohit on 02/05/26.
//

import ComposableArchitecture
import XCTest
@testable import TaskFlowTCA

final class TaskListFeatureTests: XCTestCase {
    @MainActor
    func test_loadTasks() async {
        let mockRepo = MockTaskRepository()
        mockRepo.storedTasks = [
            TaskItem(id: UUID(), title: "Test", priority: .normal, status: .todo, createdAt: Date())
        ]

        let store = TestStore(initialState: TaskListFeature.State()) {
            TaskListFeature()
        } withDependencies: {
            $0.taskRepository.fetchTasks = { try await mockRepo.fetchTasks() }
            $0.taskRepository.addTask = { try await mockRepo.addTask($0) }
            $0.taskRepository.updateTask = { try await mockRepo.updateTask($0) }
            $0.taskRepository.deleteTask = { try await mockRepo.deleteTask(id: $0) }
        }

        await store.send(.loadTasks)
        await store.receive(.tasksResponse(mockRepo.storedTasks)) {
            $0.tasks = mockRepo.storedTasks
        }
    }

    @MainActor
    func test_addTask() async {
        let mockRepo = MockTaskRepository()
        let newTask = TaskItem(id: UUID(), title: "New", priority: .normal, status: .todo, createdAt: Date())

        let store = TestStore(initialState: TaskListFeature.State()) {
            TaskListFeature()
        } withDependencies: {
            $0.taskRepository.fetchTasks = { try await mockRepo.fetchTasks() }
            $0.taskRepository.addTask = { try await mockRepo.addTask($0) }
            $0.taskRepository.updateTask = { try await mockRepo.updateTask($0) }
            $0.taskRepository.deleteTask = { try await mockRepo.deleteTask(id: $0) }
        }

        await store.send(.addTask(newTask))
        // After add, it triggers loadTasks, which returns updated list
        await store.receive(.loadTasks)
        // Mock repository now contains the new task
        mockRepo.storedTasks.append(newTask)
        await store.receive(.tasksResponse([newTask])) {
            $0.tasks = [newTask]
        }
    }

    @MainActor
    func test_filterAndSearch() async {
        let tasks = [
            TaskItem(id: UUID(), title: "Buy groceries", priority: .normal, status: .todo, createdAt: Date()),
            TaskItem(id: UUID(), title: "Call dentist", priority: .high, status: .inProgress, createdAt: Date())
        ]
        let mockRepo = MockTaskRepository()
        mockRepo.storedTasks = tasks

        let store = TestStore(initialState: TaskListFeature.State()) {
            TaskListFeature()
        } withDependencies: {
            $0.taskRepository.fetchTasks = { try await mockRepo.fetchTasks() }
            $0.taskRepository.addTask = { try await mockRepo.addTask($0) }
            $0.taskRepository.updateTask = { try await mockRepo.updateTask($0) }
            $0.taskRepository.deleteTask = { try await mockRepo.deleteTask(id: $0) }
        }

        await store.send(.loadTasks)
        await store.receive(.tasksResponse(tasks)) {
            $0.tasks = tasks
        }

        // Test filter
        await store.send(.binding(.set(\.filterStatus, .inProgress))) {
            $0.filterStatus = .inProgress
            // filteredTasks should be updated automatically (computed)
        }
        XCTAssertEqual(store.state.filteredTasks.count, 1)
        XCTAssertEqual(store.state.filteredTasks.first?.status, .inProgress)

        // Test search
        await store.send(.binding(.set(\.searchText, "dentist"))) {
            $0.searchText = "dentist"
        }
        XCTAssertEqual(store.state.filteredTasks.count, 1)
        XCTAssertTrue(store.state.filteredTasks.first?.title.contains("dentist") ?? false)
    }
}
