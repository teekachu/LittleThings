//
//  TaskManager.swift
//  One Three Five
//
//  Created by Seek, David on 12/10/20.
//

import Foundation
import Loaf

class TaskManager {
    
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        addTasksListener()
    }
    
    private var tasks: [Task] = [] {
        didSet {
            taskObserver?(tasks)
        }
    }
    
    private var taskObserver: (([Task]) -> Void)?
    
    // MARK: - Public
    
    public func setTaskObserver(onChange: @escaping ([Task]) -> Void) {
        addTasksListener()
        taskObserver = onChange
        taskObserver?(tasks)
    }
    
    /// Delete - Determine if adding this task will break the 1-3-5 rule?
    //    public func currentTasktypeMeetsRestriction(for task: Task) -> String? {
    //        /// basically determine whether the user is adding too many tasks or not.
    //
    //        let typeOne = tasks.filter{ $0.taskType == .one }
    //        let typeThree = tasks.filter{ $0.taskType == .three }
    //        let typeFive = tasks.filter{ $0.taskType == .five }
    //
    //        if typeOne.count == 1
    //            && typeThree.count == 3
    //            && typeFive.count == 5 {
    //            return "Currently have 9 tasks ongoing already"
    //        } else {
    //            if task.taskType == .one && typeOne.count > 0 {
    //                return "Already have 1 large task"
    //            } else if task.taskType == .three && typeThree.count > 2 {
    //                return "Already have 3 medium tasks"
    //            } else if task.taskType == .five && typeFive.count > 4 {
    //                return "Already have 5 small tasks"
    //            }
    //        }
    //        return nil
    //    }
    
    public func store(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        databaseManager.addTask(task) { result in
            switch result{
            case .success:
                onResult(.success, "New task added!")
                
            case .failure(let error):
                print(error.localizedDescription)
                onResult(.error, "Uh oh, something went wrong.")
            }
        }
    }
    
    public func updateTaskStatus(_ task: Task, isDone: Bool, onResult: @escaping (Loaf.State, String) -> Void) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(for: id, isDone: isDone) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                onResult(.error, toastMessages.uhOhErr)
                
            case .success:
                switch isDone{
                case true:
                    onResult(.success, "Moved task to done. Good job!")
                case false:
                    onResult(.success, "Still working on that? No problem!")
                }
            }
        }
    }
    
    public func edit(task: Task, onResult: @escaping (Loaf.State, String) -> Void){
        databaseManager.editTask(for: task) { (result) in
            switch result{
            case .failure(let error):
                print(error.localizedDescription)
                onResult(.error, toastMessages.uhOhErr)
            case .success:
                onResult(.success, "Updated task successfully!")
            }
        }
    }
    
    public func delete(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        guard let id = task.id else { return }
        databaseManager.deleteTask(for: id) { result in
            switch result{
            case.failure(let error):
                print("DEBUG: error in deleteTask: \(error.localizedDescription)")
                onResult(.error, "Uh Oh, something went wrong.")
            case.success:
                onResult(.success, "Task has been deleted successfully.")
            }
        }
    }
    
    public func emptyTasksBeforeLogOut(){
        self.tasks = []
    }
    
    // MARK: - Private
    /// Pulls task through using the databaseManager
    private func addTasksListener() {
        guard let currentUserUID = AuthManager.fetchUserUID() else {
            print("DEBUG error in addTasksListener: Cannot fetch uid")
            return
        }
        
        databaseManager.getTasks(for: currentUserUID) { [weak self] tasks in
            self?.tasks = tasks
        }
    }
    
}
