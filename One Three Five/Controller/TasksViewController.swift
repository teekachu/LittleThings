//
//  TasksViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf

class TasksViewController: UIViewController, Animatable {
    
    //  MARK: Properties
    private let databaseManager = DatabaseManager()
    private let ongoingViewController = OngoingTableViewController()
    private let doneViewController = DoneTableViewController()
    
    
    //  MARK: IB Properties
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var outerStackView: UIStackView!
    
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSegmentControlUI()
        configureContainerViews()
        /// TODO: Need to update this later for auth. 
//        presentOnboardingController()
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
    
    
    //  MARK: Privates UI-Config
    private func configureUI(){
        /// white in lightmode, med black in darkmode
        view.backgroundColor = Constants.navBarColor
        navigationController?.navigationBar.isHidden = true
        
        segment.backgroundColor = Constants.segmentBarBackground
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Constants.blackBlack ?? #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1),
                                        NSAttributedString.Key.font: UIFont(name: Constants.fontMedium, size: 16)!]
                                       ,for: UIControl.State.normal)
        
        ///TODO: Change date label text
        dateLabel.text = Date().convertToString()
        dateLabel.textColor = Constants.smallTextNavBarColor
        
        /// TODO: Update label text
        greetingsLabel.text = "Hello, Teeks!"
        greetingsLabel.textColor = Constants.smallTextNavBarColor
        
        /// TODO: Update quotes text
        quotesLabel.text = "Little things make big days!"
        quotesLabel.layer.cornerRadius = 5
        quotesLabel.numberOfLines = 0
        quotesLabel.textColor = Constants.navBarQuoteTextColor
        
        actionButton.backgroundColor = Constants.addTaskButton
        actionButton.tintColor = .white
        actionButton.setTitle("+ Add Task", for: .normal)
        actionButton.titleLabel?.font = UIFont(name: Constants.fontMedium, size: 16)
        actionButton.layer.cornerRadius = 12
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func configureSegmentControlUI(){
        segment.removeAllSegments()
        segment.insertSegment(withTitle: "Ongoing", at: 0, animated: false)
        segment.insertSegment(withTitle: "Done", at: 1, animated: false)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
    }
    
    private func configureContainerViews(){
        
        addChild(ongoingViewController)
        view.addSubview(ongoingViewController.view)
        ongoingViewController.delegate = self
        ongoingViewController.view.anchor(
            top: outerStackView.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 5)
        
        addChild(doneViewController)
        view.addSubview(doneViewController.view)
        doneViewController.view.anchor(
            top: outerStackView.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 5)
        
        ongoingViewController.view.alpha = 1
        doneViewController.view.alpha = 0
        
        /// layout subviews immedietly
        ongoingViewController.view.layoutIfNeeded()
        doneViewController.view.layoutIfNeeded()
    }
    
    //  MARK: Privates methods
    private func deleteTask(for id: String){
        databaseManager.deleteTask(for: id) {[weak self] (result) in
            guard let self = self else {return}
            switch result{
            case.failure(let error):
                self.printDebug(message: "deleteTask: \(error.localizedDescription)")
                self.showToast(state: .error, message: "Uh Oh, something went wrong.")
            case.success:
                self.showToast(state: .success, message: "Task has been deleted successfully.")
            }
        }
    }
    
    private func editTask(for task: Task){
        /// open new task vc to edit
        let modalVC = AddNewTaskViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .overCurrentContext
        modalVC.modalTransitionStyle = .crossDissolve
        modalVC.taskToEdit = task
        present(modalVC, animated: true)
    }
    
    private func presentOnboardingController(){
        let cont = OnboardingViewController()
        cont.modalPresentationStyle = .fullScreen
        present(cont, animated: true)
    }
}


//  MARK: Extensions
extension TasksViewController: NewTaskVCDelegate {
    
    func didAddTask(for task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {[unowned self] in
            
            self.databaseManager.addTask(task) {[unowned self] (result) in
                switch result{
                case .success:
                    self.showToast(state: .success, message: "New task added!")
                    
                case .failure(let error):
                    printDebug(message: error.localizedDescription)
                    self.showToast(state: .error, message: "Uh oh, something went wrong.")
                }
            }
        })
    }
    
    func didEditTask(for task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {[weak self] in
            
            guard let id = task.id else {return}
            
            self?.databaseManager.editTask(for: id, title: task.title, tasktype: task.taskType) {[weak self] (result) in
                switch result{
                case .success:
                    self?.showToast(state: .success, message: "Task updated!")
                    
                case .failure(let error):
                    self?.printDebug(message: error.localizedDescription)
                    self?.showToast(state: .error, message: "Uh oh, \(error.localizedDescription).")
                }
            }
        })
    }
    
    
}


extension TasksViewController: OngoingTasksTVCDelegate {
    /// The parent view will act as the delegate for the child.
    /// when a cell is selected in the child, the child will be notified ( need an intern to pass on information)
    /// The parent will act as the intern , take the information and execiutes methods.
    func showOptions(for task: Task){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let edit = UIAlertAction(title: "Edit", style: .default) {[unowned self] (_) in
            editTask(for: task)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) {[unowned self] (_) in
            /// use unowned self when we are confident that self will never be nil.
            guard let id = task.id else {return}
            self.deleteTask(for: id)
        }
        alert.addAction(cancel)
        alert.addAction(edit)
        alert.addAction(delete)
        
        alert.view.tintColor = Constants.blackWhite
        
        present(alert, animated: true)
    }
    
}

