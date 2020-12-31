//
//  DataSource.swift
//  One Three Five
//
//  Created by Tee Becker on 12/5/20.
//

import UIKit
import Firebase

/// Conforms to UITableviewDatasource
class DataSource: UITableViewDiffableDataSource<TaskType, Task> {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TaskType.allCases[section].rawValue // "One Large" / "Three medium" etc..
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            var snapshot = self.snapshot()
            if let item = itemIdentifier(for: indexPath) {
                // remove from snapshot
                snapshot.deleteItems([item])
                apply(snapshot, animatingDifferences: true)
                
                // remove from firebase
                guard let id = item.id else {return}
                Firestore.firestore().collection("tasks").document(id).delete()
            }
        }
    }
    
}


