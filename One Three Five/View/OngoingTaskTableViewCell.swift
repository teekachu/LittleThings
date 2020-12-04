//
//  TaskTableViewCell.swift
//  One Three Five
//
//  Created by Tee Becker on 12/2/20.
//

import UIKit

class OngoingTaskTableViewCell: UITableViewCell {

    //  MARK: Properties
    var actionButtonDidTap: (() -> Void)?
    
    
    //  MARK: IB Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBAction func actionButtonTapped(){
        /// inform the OngoingTaskTableViewController using a closure ( or can use protocol/delegate)
        actionButtonDidTap?()
    }
    
    
    //  MARK: Public
    func configureTaskCell(with task: Task){
        titleLabel.text = task.title
    }
}
