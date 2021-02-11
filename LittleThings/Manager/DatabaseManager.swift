//
//  DataManager.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

//protocol DatabaseManagerDelegate: class {
//    func databaseManager(didSignalUserAuthenticationFor userID: String)
//}

class DatabaseManager {

//    private let delegate: DatabaseManagerDelegate
    private let tasksCollection = Firestore.firestore().collection("tasks")
    private let userCollection = Firestore.firestore().collection("Users")

//    init(delegate: DatabaseManagerDelegate) {
//        self.delegate = delegate
//    }

    func setUser(_ data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion) {
        userCollection.document(userID).setData(data, completion: onComplete)
    }

    func updateUser(_ data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion) {
        userCollection.document(userID).updateData(data, completion: onComplete)
    }

    func getDataFor(_ userID: String, onCompletion: @escaping ([String : Any]) -> Void) {
        userCollection.document(userID).getDocument { (snapshot, error) in
            guard error == nil else {
                // MARK: - TODO, handle appropriately
                return
            }
            guard let snapshot = snapshot, let data = snapshot.data() else {
                // MARK: - TODO, handle appropriately
                return
            }
            onCompletion(data)
        }
    }

    
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

    // Triggers new badge count down to AppDelegate
//    public func notifyUserDidAuthSuccessfully(userID: String) {
//        delegate.databaseManager(didSignalUserAuthenticationFor: userID)
//    }

    // Returns the number of open tasks
    public func getBadgeCount(for userID: String, onLoad: @escaping (Int) -> Void) {
        tasksCollection
            .whereField("uid", isEqualTo: userID)
            .whereField("isDone", isEqualTo: false)
            .addSnapshotListener { (snapshot, error) in

                guard error == nil else {
                    print("DEBUG: error in getTasks \(error!.localizedDescription)")
                    onLoad(0)
                    return
                }

                do {
                    let decodedTasks = try snapshot?.documents.compactMap {
                        return try $0.data(as: Task.self)
                    } ?? []

                    onLoad(decodedTasks.count)

                } catch let error {
                    print("DEBUG: error in getTasks \(error.localizedDescription)")
                    onLoad(0)
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
