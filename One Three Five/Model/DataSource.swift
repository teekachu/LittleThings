//
//  DataSource.swift
//  One Three Five
//
//  Created by Tee Becker on 12/5/20.
//

import UIKit

/// Conforms to UITableviewDatasource
class DataSource: UITableViewDiffableDataSource<TaskType, Task> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TaskType.allCases[section].rawValue // "One Large" / "Three medium" etc..
    }
}
