//
//  UITableView.swift
//  One Three Five
//
//  Created by Seek, David on 12/10/20.
//

import UIKit

enum CellIdentifier: String {
    case ongoing = "OngoingTaskTableViewCell"
    case done = "DoneTaskTableViewCell"
}

extension UITableView {
    func registerCell(_ identifier: CellIdentifier) {
        register(
            UINib(nibName: identifier.rawValue, bundle: nil),
            forCellReuseIdentifier: identifier.rawValue
        )
    }
}
