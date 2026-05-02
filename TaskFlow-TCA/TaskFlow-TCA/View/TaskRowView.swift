//
//  TaskRowView.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .done, color: .secondary)

                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Circle()
                .fill(priorityColor)
                .frame(width: 12, height: 12)

            Text(task.status.rawValue)
                .font(.caption2)
                .padding(6)
                .background(statusColor.opacity(0.2), in: Capsule())
                .foregroundColor(statusColor)
        }
        .padding(.vertical, 4)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: .green
        case .normal: .orange
        case .high: .red
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .todo: .blue
        case .inProgress: .purple
        case .done: .gray
        }
    }
}
