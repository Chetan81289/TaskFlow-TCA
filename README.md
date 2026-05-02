# TaskFlow – The Composable Architecture (TCA)

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Xcode-16.0+-blueviolet" alt="Xcode 16+">
  <img src="https://img.shields.io/badge/Architecture-TCA-8A2BE2" alt="Architecture">
  <img src="https://img.shields.io/badge/Persistence-Core%20Data-lightgrey" alt="Core Data">
  <img src="https://img.shields.io/badge/Tests-Passing-brightgreen" alt="Tests">
</p>

A **production‑grade task manager** built with **The Composable Architecture (TCA)** – a powerful, testable framework for state management.  
It uses **SwiftUI**, **Core Data**, and **Swift Concurrency** to deliver the same feature set as its MVVM counterparts, but with an **explicit, unidirectional data flow** and fully testable side effects.

> **Part of a multi‑architecture series** – the same app is also implemented with **MVVM+Combine** and **MVVM+async/await**.  
> This version proves you can ship with **TCA**, a framework favoured by many forward‑thinking iOS teams.

---

## 📱 Features

- Create, edit, delete, and search tasks
- Filter by status (To‑Do, In‑Progress, Done)
- Priority levels (Low, Normal, High) with visual indicators
- Due date support
- Offline‑first: all data persisted locally with Core Data
- Unidirectional data flow with a **Reducible state**
- Side effects managed by **Effects** and a dependency‑injected repository client
- Graceful error handling (can be extended easily)
- Full **test suite** using TCA’s `TestStore`

---

## 🧱 Architecture – The Composable Architecture
┌──────────────────────────────────────────┐
│ SwiftUI Views │
│ TaskListView, TaskRow, AddEditTaskView │
│ WithViewStore(store, observe: …) │
│ store.send(.addTask(newTask)) │
└────────────────┬─────────────────────────┘
│ send actions
┌────────────────▼─────────────────────────┐
│ TaskListFeature (Reducer & State) │
│ - State: tasks, filter, search… │
│ - Action: loadTasks, addTask, delete… │
│ - Reducer: pure in‑out, no side effects │
│ - Effects: calls taskRepository client │
└────────────────┬─────────────────────────┘
│ uses Dependency
┌────────────────▼─────────────────────────┐
│ TaskRepositoryClient │
│ (struct with closures, live / test) │
│ Injecteed via @Dependency(.taskRepo) │
└──────────────────────────────────────────┘
---
**What sets this apart for your team:**

- **Explicit state and actions** – every mutation is a traceable action, making debugging trivial.
- **Zero side effects in the reducer** – all data operations run as effects, keeping the core logic pure.
- **Testability at every level** – you can test not just state changes but also how effects feed back actions using `TestStore`.
- **Dependency injection built‑in** – swap the live database for a mock without any property injection or protocols.
- **Scalable** – features compose naturally, so adding new functionality (e.g., push notifications, sharing) follows the same pattern.

---

## 🛠 Tech Stack

| Layer            | Technology                          |
|------------------|-------------------------------------|
| UI               | SwiftUI                             |
| State Management | TCA (Reducer + Store)               |
| Dependency       | TCA’s `@Dependency`                 |
| Persistence      | Core Data                           |
| Concurrency      | Swift Concurrency (async/await)     |
| Testing          | XCTest + TCA `TestStore`            |
| Minimum Target   | iOS 17.0                            |
| Language         | Swift 6                             |

---

## 📂 Project Structure

```
TaskFlow-TCA/
├── App/
│   ├── TaskFlowApp.swift                  # @main, creates Store
│   └── PersistenceController.swift        # Core Data stack
├── Model/
│   ├── TaskItem.swift                     # Domain model (renamed from Task)
│   ├── TaskEntity+CoreDataClass.swift     # Core Data entity (manual)
│   └── TaskEntity+Mapping.swift           # Entity ↔ Domain mapping
├── CoreData/
│   └── TaskFlow.xcdatamodeld              # Data model file
├── Repository/
│   ├── CoreDataTaskRepository.swift       # Core Data async operations
│   └── TaskRepositoryClient.swift         # TCA dependency (live + test)
├── Feature/
│   ├── TaskListFeature.swift              # Reducer, State, Action
│   └── TaskListView.swift                 # Main screen (Store)
├── View/
│   ├── TaskRowView.swift                  # Row cell
│   └── AddEditTaskView.swift              # New/Edit sheet
└── Tests/
    ├── TaskListFeatureTests.swift         # TCA test store tests
    └── MockTaskRepository.swift           # Mock for fast testing
```
## 📬 Contact
Chetan Purohit
iOS Developer
Chetan81289@outlook.com
