//
//  Task.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit
import FirebaseFirestoreSwift


struct Task: Identifiable, Codable, Hashable {
    
    @DocumentID var id: String?  /// This is Hashable
    @ServerTimestamp var createdAt: Date?
    var title: String?
    var isDone: Bool = false
    var doneAt: Date?
    var taskType: TaskType
    let uid: String
    
    public static func basic(for userID: String) -> Task {
        return Task(
            title: nil,
            taskType: .three,
            uid: userID)
    }
    
}



