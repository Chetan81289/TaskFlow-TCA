//
//  TaskListFeature.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TaskListFeature {
    @ObservableState
    struct State: Equatable {
        var tasks: [TaskItem] = []
        var filterStatus: TaskItem.TaskStatus? = nil
        var searchText: String = ""
        var errorMessage: String?

        // Filtered and sorted tasks computed from state
        var filteredTasks: [TaskItem] {
            tasks
                .filter { task in
                    (filterStatus == nil || task.status == filterStatus) &&
                    (searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText))
                }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case task(TaskAction)
        case loadTasks
        case tasksResponse([TaskItem])
        case addTask(TaskItem)
        case updateTask(TaskItem)
        case deleteTask(UUID)
        case errorMessageTimeout
    }

    @CasePathable
    enum TaskAction: Equatable {
        case delete(indexSet: IndexSet)
    }

    @Dependency(\.taskRepository) var taskRepository
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .task(.delete(let indexSet)):
                guard let index = indexSet.first else { return .none }
                let task = state.filteredTasks[index]
                return .send(.deleteTask(task.id))

            case .loadTasks:
                return .run { send in
                    let tasks = try await taskRepository.fetchTasks()
                    await send(.tasksResponse(tasks))
                } catch: { error, send in
                    // error handling could be added here
                }

            case .tasksResponse(let tasks):
                state.tasks = tasks
                return .none

            case .addTask(let task):
                return .run { send in
                    try await taskRepository.addTask(task)
                    await send(.loadTasks)
                } catch: { error, send in
                    // handle error
                }

            case .updateTask(let task):
                return .run { send in
                    try await taskRepository.updateTask(task)
                    await send(.loadTasks)
                } catch: { error, send in
                    // handle error
                }

            case .deleteTask(let id):
                return .run { send in
                    try await taskRepository.deleteTask(id)
                    await send(.loadTasks)
                } catch: { error, send in
                    // handle error
                }

            case .errorMessageTimeout:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
