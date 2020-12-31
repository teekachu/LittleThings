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
    
    
    public func currentTasktypeMeetsRestriction(for task: Task) -> String? {
        /// basically determine whether the user is adding too many tasks or not.
        let warningMsg = "Try to finish the existing tasks before adding more."
        
        let typeOne = tasks.filter{ $0.taskType == .one && !$0.isDone }
        let typeThree = tasks.filter{ $0.taskType == .three && !$0.isDone }
        let typeFive = tasks.filter{ $0.taskType == .five && !$0.isDone }
        
        if typeOne.count == 1
            && typeThree.count == 3
            && typeFive.count == 5 {
            return "You already have 9 tasks ongoing, why don't you finish some before adding more?  "
            
        } else {
            if task.taskType == .one && typeOne.count > 0 ||
                task.taskType == .three && typeThree.count > 2 ||
                task.taskType == .five && typeFive.count > 4 {
                return warningMsg
            }
        }
        return nil
    }
    
    
    public func store(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        databaseManager.addTask(task) { result in
            switch result{
            case .success:
                onResult(.success, "New task added!")
                
            case .failure(let error):
                print("DEBUG: error in store(), \(error.localizedDescription)")
                onResult(.error, "Uh oh, something went wrong.")
            }
        }
    }
    
    public func updateTaskStatus(_ task: Task, isDone: Bool, onResult: @escaping (Loaf.State, String) -> Void) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(for: id, isDone: isDone) { result in
            switch result {
            case .failure(let error):
                print("DEBUG: error in updateTaskStatus(), \(error.localizedDescription)")
                onResult(.error, "Uh oh, something went wrong...")
                
            case .success:
                switch isDone{
                case true:
                    //                    break
                    onResult(.success, "Good job on wrapping this up!")
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
                print("DEBUG: error in edit(), \(error.localizedDescription)")
                onResult(.error, "Uh oh, something went wrong...")
            case .success:
                onResult(.success, "Updated successfully!")
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
                break
            //                onResult(.success, "Task has been deleted successfully.")
            }
        }
    }
    
    public func emptyTasksBeforeLogOut(){
        self.tasks = []
    }
    
    public func deleteAll(tasks: [Task]){
        databaseManager.deleteAll(in: tasks)
    }
    
    
    // MARK: - Private
    /// Pulls task through using the databaseManager
    private func addTasksListener() {
        guard let currentUserUID = AuthManager.fetchUserUID() else {
            return
        }
        
        databaseManager.getTasks(for: currentUserUID) { [weak self] tasks in
            self?.tasks = tasks
        }
    }
    
}
