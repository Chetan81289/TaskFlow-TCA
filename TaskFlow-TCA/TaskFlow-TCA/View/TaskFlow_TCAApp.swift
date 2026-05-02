//
//  TaskFlow_TCAApp.swift
//  TaskFlow-TCA
//
//  Created by Jyoti Purohit on 02/05/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct TaskFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TaskListView(
                store: Store(initialState: TaskListFeature.State()) {
                    TaskListFeature()
                }
            )
            .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
