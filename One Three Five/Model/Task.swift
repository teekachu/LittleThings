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
    let title: String
    var isDone: Bool = false
    var doneAt: Date?
    var taskType: TaskType
    
    /// I dont even think i need this... DocumentID is already unique / Hashable isnt it ?
//    /// Implement the hashable property for id
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
    
    // TEST DATA:
    static func testData() -> [Task] {
        return [
            Task(title: "Code", taskType: .three),
            Task(title: "Workout", taskType: .one),
            Task(title: "Run", taskType: .five),
            Task(title: "Eat", taskType: .five)
        ]
    }
}


