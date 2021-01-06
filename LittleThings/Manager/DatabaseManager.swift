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
    
    private let tasksCollection = Firestore.firestore().collection("tasks")
    
    /// To add new task into firebase
    public func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    /// To delete task from firebase
    public func deleteTask(for id: String, completion: @escaping (Result<Void, Error>) -> Void ){
        tasksCollection.document(id).delete { (error) in
            if let error = error{
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func deleteAll(in array: [Task]){
        array.forEach {
            guard let id = $0.id else {return}
            tasksCollection.document(id).delete()
        }
    }
    
    
    /// To edit content for a spcific task taking into the id.
    public func editTask(for task: Task, completion: @escaping (Result<Void, Error>) -> Void){
        guard let id = task.id else { return }
        let data: [String: Any] = ["title": task.title ?? "", "taskType": task.taskType.rawValue]
        tasksCollection.document(id).updateData(data) { (error) in
            if let error = error{
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// To update whether a task is done or not. move back and forth between Done &&  Ongoing tab
    public func updateTaskStatus(for id: String, isDone: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    /// Added index in firebase maually to help with querying
    public func getTasks(for uid: String, onLoad: @escaping ([Task]) -> Void){
        tasksCollection
            .whereField("uid", isEqualTo: uid)
            .order(by: "createdAt", descending: true) // latest task appear on top
            .addSnapshotListener { (snapshot, error) in
                
                guard error == nil else {
                    print("DEBUG: error in getTasks \(error!.localizedDescription)")
                    return
                }
                
                do {
                    let decodedTasks = try snapshot?.documents.compactMap {
                        return try $0.data(as: Task.self)
                    } ?? []
                    
                    onLoad(decodedTasks)
                    
                } catch let error {
                    print("DEBUG: error in getTasks \(error.localizedDescription)")
                }
            }
    }
    
    
    public func getSingleTask(for documentId: String, onLoad: @escaping (Task) -> Void ){
        let docRef = tasksCollection.document(documentId)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error in getSingleTask - \(error.localizedDescription) ")
                return
            }
            if let docData = try? document?.data(as: Task.self) {
                onLoad(docData)
            }
        }
    }
    
}
