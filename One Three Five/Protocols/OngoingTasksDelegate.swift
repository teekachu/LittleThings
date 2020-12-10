//
//  OngoingTasksDelegate.swift
//  One Three Five
//
//  Created by Tee Becker on 12/10/20.
//

import Foundation

///135 - 
protocol OngoingTasksDelegate: class {
    func currentTasktypeMeetsRestriction(for task: Task, completion: @escaping (String?) -> Void)
}
