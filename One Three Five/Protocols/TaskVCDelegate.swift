//
//  TaskVCDelegate.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import Foundation

protocol TaskVCDelegate: class {
    func didAddTask(for task: Task)
}
