//
//  TaskTableViewCell.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit

class OngoingTaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    private var tapObserver: (() -> Void)?
    
    @IBAction func actionButtonTapped() {
        tapObserver?()
    }
}
 
// MARK: - Taskable
extension OngoingTaskTableViewCell: Taskable {
    
    func configureTaskCell(with task: Task){
        titleLabel.text = task.title
        guard let createdAt = task.createdAt?.convertToSimplifiedTimeString() else {return}
        deadlineLabel.text = "Created at: \(createdAt)"
    }
    
    func setTapObserver(onTab: @escaping () -> Void) {
        tapObserver = onTab
    }
}
