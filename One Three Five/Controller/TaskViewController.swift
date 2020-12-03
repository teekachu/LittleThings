//
//  ViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf

class TaskViewController: UIViewController {
    
    //  MARK: Properties
    private let databaseManager = DatabaseManager()
    
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
    private let ongoingViewController = OngoingTableViewController()
    private let doneViewController = DoneTableViewController()
    
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
            ongoingViewController.view.alpha = 1
            doneViewController.view.alpha = 0
        case 1:
            ongoingViewController.view.alpha = 0
            doneViewController.view.alpha = 1
        default:
            break
        }
    }
    
    @objc func actionButtonTapped(){
        let modalVC = AddNewTaskViewController()
        modalVC.delegate = self
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

        addChild(ongoingViewController)
        view.addSubview(ongoingViewController.view)
        ongoingViewController.view.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: bottomView.topAnchor,
            right: view.rightAnchor)
        
        addChild(doneViewController)
        view.addSubview(doneViewController.view)
        doneViewController.view.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: bottomView.topAnchor,
            right: view.rightAnchor)
        
        ongoingViewController.view.alpha = 1
        doneViewController.view.alpha = 0
        
        /// layout subviews immedietly
        ongoingViewController.view.layoutIfNeeded()
        doneViewController.view.layoutIfNeeded()
    }
}


//  MARK: Extensions
extension TaskViewController: TaskVCDelegate, Animatable {
    
    func didAddTask(for task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {[unowned self] in
            
            self.databaseManager.addTask(task) {[unowned self] (result) in
                switch result{
                case .success:
                    self.showToast(state: .success, message: "New task added!", location: .top, duration: 1.5)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.showToast(state: .error, message: "Uh oh, something went wrong.", location: .top, duration: 2)
                }
            }
        })
    }
    
    
}
