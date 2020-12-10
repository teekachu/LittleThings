//
//  TaskVCDelegate.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import Foundation

protocol NewTaskVCDelegate: class {
//    func canAddTask(for task: Task) /// New
    func didAddTask(for task: Task)
    func didEditTask(for task: Task)
}
