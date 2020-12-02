//
//  doneTaskContainerView.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class DoneTaskTableViewController: UIView {
    //  MARK: Properties
    
    //  MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(){
        backgroundColor = .green
    }
}
