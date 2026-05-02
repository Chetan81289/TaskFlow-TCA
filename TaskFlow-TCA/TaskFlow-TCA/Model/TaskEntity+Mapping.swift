//
//  TaskEntity+Mapping.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

extension TaskEntity {
    var domainModel: TaskItem {
        TaskItem(
            id: self.id,
            title: self.title,
            details: self.details,
            priority: TaskItem.Priority(rawValue: Int(self.priority)) ?? .normal,
            status: TaskItem.TaskStatus(rawValue: self.status) ?? .todo,
            createdAt: self.createdAt,
            dueDate: self.dueDate
        )
    }

    func update(from task: TaskItem) {
        self.id = task.id
        self.title = task.title
        self.details = task.details
        self.priority = Int16(task.priority.rawValue)
        self.status = task.status.rawValue
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
    }
}
