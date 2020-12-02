//
//  OngoingTaskContainerView.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class OngoingTaskContainerView: UIView {
    
    //  MARK: Properties
    
    //  MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        configureView()
        configureTableview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(){
        backgroundColor = .clear
    }
    
    private func configureTableview(){
        let tableviewcontroller = OngoingTableViewController()
        addSubview(tableviewcontroller.view)
    }
}
