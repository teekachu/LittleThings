//
//  Task.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit
import FirebaseFirestoreSwift

struct Task: Identifiable, Codable {
    
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Date?
    let title: String
    var isDone: Bool = false
    var doneAt: Date?
    let taskType: String
}
