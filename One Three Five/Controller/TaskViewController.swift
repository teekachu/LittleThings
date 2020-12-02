//
//  ViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class TaskViewController: UIViewController {
    
    //  MARK: Properties
    private let segment: UISegmentedControl = {
        let segmentItems = ["Ongoin", "Done"]
        let segment = UISegmentedControl(items: segmentItems)
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        let addimage = UIImage(systemName: "plus")
        btn.setImage(addimage, for: .normal)
        return btn
    }()
    
    /// container view is going to hold the tableviewcontrollers.
    private let ongoingTaskContainerView = OngoingTaskContainerView()
    private let doneTaskContainerView = DoneTaskContainerView()
    
//    private lazy var boardmanager: BLTNItemManager = {
//        let title = "Add Task"
//        let item = BLTNPageItem(title: title)
//        item.image = UIImage(named: "text-editor-icon")
//        item.actionButtonTitle = "Continue"
//        item.alternativeButtonTitle = "Maybe later"
//        item.descriptionText = "Some stuff "
//        item.actionHandler = { _ in
//            /// call function
//        }
//        item.alternativeHandler = { _ in
//            /// call function
//        }
//        return BLTNItemManager(rootItem: item)
//    }()
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSegmentControlUI()
        configureBottomView()
        configureContainerViews()
        configureActionButton()
    }
    
    
    //  MARK: Selectors
    @objc func segmentedControl(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            ongoingTaskContainerView.isHidden = false
            doneTaskContainerView.isHidden = true
        case 1:
            ongoingTaskContainerView.isHidden = true
            doneTaskContainerView.isHidden = false
        default:
            break
        }
    }
    
    @objc func actionButtonTapped(){
        let modalVC = NewTaskViewController()
        modalVC.modalPresentationStyle = .overCurrentContext
        modalVC.modalTransitionStyle = .crossDissolve
        present(modalVC, animated: true)
    }
    
    
    //  MARK: Privates
    private func configureUI(){
        title = "Tasks"
        navigationItem.titleView = segment
        navigationItem.titleView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ongoingTaskContainerView.isHidden = false
        doneTaskContainerView.isHidden = true
        navigationController?.navigationBar.isHidden = false
    }
    
    private func configureSegmentControlUI(){
        //TODO: Update color
        segment.backgroundColor = Constants.backgroundColor
        segment.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        segment.sizeToFit()
        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
    }
    
    private func configureBottomView(){
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            height: 80)
        /// TODO: Change color
        bottomView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    }
    
    private func configureActionButton(){
        view.addSubview(actionButton)
        actionButton.centerX(inView: view)
        actionButton.centerX(inView: view, topAnchor: bottomView.firstBaselineAnchor, paddingTop: -30)
        actionButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        actionButton.tintColor = .white
        actionButton.anchor(
            width: 60,
            height: 60)
        actionButton.layer.cornerRadius = 20
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func configureContainerViews(){
        view.addSubview(ongoingTaskContainerView)
        ongoingTaskContainerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: bottomView.topAnchor,
            right: view.rightAnchor)
        
        view.addSubview(doneTaskContainerView)
        doneTaskContainerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: bottomView.topAnchor,
            right: view.rightAnchor)
    }
}


//  MARK: Extensions
