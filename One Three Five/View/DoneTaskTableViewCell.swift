//
//  DoneTaskTableViewCell.swift
//  One Three Five
//
//  Created by Tee Becker on 12/3/20.
//

import UIKit

class DoneTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    private var tapObserver: (() -> Void)?
    
    @IBAction func actionButtonTapped() {
        tapObserver?()
    }
}

// MARK: - Taskable
extension DoneTaskTableViewCell: Taskable {
    
    func configureTaskCell(with task: Task){
        titleLabel.text = task.title
        guard let completedtime = task.doneAt?.convertToSimplifiedTimeString() else {return}
        timeStampLabel.text = "Completed at: \(completedtime)"
    }
    
    func setTapObserver(onTab: @escaping () -> Void) {
        tapObserver = onTab
    }
}
