//
//  DoneTaskTableViewCell.swift
//  One Three Five
//
//  Created by Tee Becker on 12/3/20.
//

import UIKit

class DoneTaskTableViewCell: UITableViewCell {

    //  MARK: Properties
    var actionButtonDidTap: (() -> Void)?
    
    
    //  MARK: IB Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBAction func actionButtonTapped(){
        actionButtonDidTap?()
    }
    
    
    //  MARK: Public
    func configureTaskCell(with task: Task){
        titleLabel.text = task.title
        
        guard let completedtime = task.doneAt?.convertToSimplifiedTimeString() else {return}
        timeStampLabel.text = "Task completed at: \(completedtime)"
    }
}
