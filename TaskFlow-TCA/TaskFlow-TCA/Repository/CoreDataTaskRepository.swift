//
//  CoreDataTaskRepository.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import CoreData
import Foundation

final class CoreDataTaskRepository {
    private let persistence: PersistenceController

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    func fetchTasks() async throws -> [TaskItem] {
        let context = persistence.viewContext
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        let entities = try context.fetch(request)
        return entities.map { $0.domainModel }
    }

    func addTask(_ task: TaskItem) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform(schedule: .immediate) {
            let entity = TaskEntity(context: context)
            entity.update(from: task)
            try context.save()
        }
    }

    func updateTask(_ task: TaskItem) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform(schedule: .immediate) {
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            guard let entity = try context.fetch(request).first else {
                throw RepositoryError.taskNotFound
            }
            entity.update(from: task)
            try context.save()
        }
    }

    func deleteTask(id: UUID) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform(schedule: .immediate) {
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            guard let entity = try context.fetch(request).first else {
                throw RepositoryError.taskNotFound
            }
            context.delete(entity)
            try context.save()
        }
    }
}

enum RepositoryError: Error, LocalizedError {
    case taskNotFound

    var errorDescription: String? {
        switch self {
        case .taskNotFound: return "Task not found"
        }
    }
}
