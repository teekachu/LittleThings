//
//  Taskable.swift
//  One Three Five
//
//  Created by Seek, David on 12/10/20.
//

import Foundation

protocol Taskable {
    func configureTaskCell(with task: Task)
    func setTapObserver(onTab: @escaping () -> Void)
}
