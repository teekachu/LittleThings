//
//  DataManager.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseManager {
    
    private let db = Firestore.firestore()
    
    private lazy var tasksCollection = db.collection("tasks")
    
    private var listener: ListenerRegistration?
    
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try tasksCollection.addDocument(from: task, completion: { (error) in
                if let error = error{
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            })
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    
    func addTaskListender(completion: @escaping (Result<[Task], Error>) -> Void){
        listener = tasksCollection.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                /// Empty array that will hode the decodable Tasks
                var decodedTasks = [Task]()
                
                snapshot?.documents.forEach({ (document) in
                    /// The FirebaseFirestoreSwift pod allow us to use decodable protocol to decode the model
                    
                    if let task = try? document.data(as: Task.self) {
                        decodedTasks.append(task)
                    }
                })
                completion(.success(decodedTasks))
            }
        })
    }
    
    
    
    
}
