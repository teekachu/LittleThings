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
    
    func deleteTask(for id: String, completion: @escaping (Result<Void, Error>) -> Void ){
        tasksCollection.document(id).delete { (error) in
            if let error = error{
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Added index in firebase maually to help with querying 
    func addTaskListener(forDoneTasks isDone: Bool, completion: @escaping (Result<[Task], Error>) -> Void){
        listener = tasksCollection
            .whereField("isDone", isEqualTo: isDone)
            .order(by: "createdAt", descending: true) // latest task appear on top
            .addSnapshotListener({ (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    var decodedTasks = [Task]()
                    
                    do{
                        decodedTasks = try snapshot?.documents.compactMap({
                            return try $0.data(as: Task.self)
                        }) ?? []
                    } catch(let error) {
                        completion(.failure(error))
                    }
                    
                    completion(.success(decodedTasks))
                    /// Empty array that will hode the decodable Tasks
                }
            })
    }
    
    func updateTaskStatus(for id: String, isDone: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        
        var fields: [String: Any] = [:]
        
        if isDone{
            fields = ["isDone": true,
                      "doneAt": Date()]
        } else {
            fields = ["isDone": false,
                      "doneAt": FieldValue.delete()]
        }
        
        tasksCollection.document(id).updateData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
