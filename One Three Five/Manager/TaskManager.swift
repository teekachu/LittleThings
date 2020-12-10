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
        taskObserver = onChange
        taskObserver?(tasks)
    }
    
    public func currentTasktypeMeetsRestriction(for task: Task) -> String? {
        
        /// basically determine whether the user is adding too many tasks or not.
        
        let typeOne = tasks.filter{ $0.taskType == .one }
        let typeThree = tasks.filter{ $0.taskType == .three }
        let typeFive = tasks.filter{ $0.taskType == .five }
        
        if typeOne.count == 1
            && typeThree.count == 3
            && typeFive.count == 5 {
            return "Currently have 9 tasks ongoing already"
        } else {
            if task.taskType == .one && typeOne.count > 0 {
                return "Already have 1 large task"
            } else if task.taskType == .three && typeThree.count > 2 {
                return "Already have 3 medium tasks"
            } else if task.taskType == .five && typeFive.count > 4 {
                return "Already have 5 small tasks"
            }
        }
        
        return nil
    }
    
    public func store(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        databaseManager.addTask(task) {[unowned self] (result) in
            switch result{
            case .success:
                onResult(.success, "New task added!")
                
            case .failure(let error):
                print(error.localizedDescription)
                onResult(.error, "Uh oh, something went wrong.")
            }
        }
    }
    
    public func update(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(for: id, isDone: true) { result in
          
            switch result {
            case .failure(let error):
                onResult(.error, toastMessages.uhOhErr)
                print(error.localizedDescription)
                
            case .success:
                /// Using the protocol / extension
                onResult(.success, "Moved task to done. Good Job!!!")
            }
        }
    }
    
    public func delete(_ task: Task, onResult: @escaping (Loaf.State, String) -> Void) {
        guard let id = task.id else { return }
        databaseManager.deleteTask(for: id) { result in
            switch result{
            case.failure(let error):
                print("deleteTask: \(error.localizedDescription)")
                onResult(.error, "Uh Oh, something went wrong.")
            case.success:
                onResult(.success, "Task has been deleted successfully.")
            }
        }
    }
    
    // MARK: - Private
    
    /// Pulls task through using the databaseManager
    private func addTasksListener(){
        databaseManager.addTaskListener(forDoneTasks: false) {[weak self] (result) in
            guard let self = self else{return}
            switch result{
            case .failure(let error):
                print("addTaskListener: \(error.localizedDescription)")
                
            case .success(let decodedTasks):
                self.tasks = decodedTasks
            }
        }
    }
}
