////
////  ViewController.swift
////  One Three Five
////
////  Created by Tee Becker on 12/1/20.
////
//
//import UIKit
//import Loaf
//
//class TaskViewController: UIViewController, Animatable {
//    
//    //  MARK: Properties
//    private let databaseManager = DatabaseManager()
//    private let ongoingViewController = OngoingTableViewController()
//    private let doneViewController = DoneTableViewController()
//    
//    //  MARK: UI Properties
//    private let segment: UISegmentedControl = {
//        let segmentItems = ["Ongoin", "Done"]
//        let segment = UISegmentedControl(items: segmentItems)
//        segment.selectedSegmentIndex = 0
//        return segment
//    }()
//    
//    private let dateLabel: UILabel = {
//        let lbl = UILabel()
//        return lbl
//    }()
//    
//    private let greetingsLabel: UILabel = {
//        let lbl = UILabel()
//        return lbl
//    }()
//    
//    private let quotesLabel: UILabel = {
//        let lbl = UILabel()
//        return lbl
//    }()
//    
//    private let bottomView: UIView = {
//        let view = UIView()
//        return view
//    }()
//    
//    private let actionButton: UIButton = {
//        let btn = UIButton(type: .system)
//        let addimage = UIImage(systemName: "plus")
//        btn.setImage(addimage, for: .normal)
//        return btn
//    }()
//    
//    
//    //    private lazy var boardmanager: BLTNItemManager = {
//    //        let title = "Add Task"
//    //        let item = BLTNPageItem(title: title)
//    //        item.image = UIImage(named: "text-editor-icon")
//    //        item.actionButtonTitle = "Continue"
//    //        item.alternativeButtonTitle = "Maybe later"
//    //        item.descriptionText = "Some stuff "
//    //        item.actionHandler = { _ in
//    //            /// call function
//    //        }
//    //        item.alternativeHandler = { _ in
//    //            /// call function
//    //        }
//    //        return BLTNItemManager(rootItem: item)
//    //    }()
//    
//    //  MARK: Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        configureSegmentControlUI()
//        configureBottomView()
//        configureContainerViews()
//        configureActionButton()
//    }
//    
//    
//    //  MARK: Selectors
//    @objc func segmentedControl(_ sender: UISegmentedControl){
//        switch sender.selectedSegmentIndex {
//        case 0:
//            ongoingViewController.view.alpha = 1
//            doneViewController.view.alpha = 0
//        case 1:
//            ongoingViewController.view.alpha = 0
//            doneViewController.view.alpha = 1
//        default:
//            break
//        }
//    }
//    
//    @objc func actionButtonTapped(){
//        let modalVC = AddNewTaskViewController()
//        modalVC.delegate = self
//        modalVC.modalPresentationStyle = .overCurrentContext
//        modalVC.modalTransitionStyle = .crossDissolve
//        present(modalVC, animated: true)
//    }
//    
//    
//    //  MARK: Privates
//    private func configureUI(){
//        navigationItem.titleView = segment
//        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        
//        /// add date label
//        dateLabel.text = "May 7, 2020" /// TODO: Fix date
//        dateLabel.font = UIFont(name: "Avenir", size: 14)
//        dateLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//        dateLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, height: 20)
//        
//        greetingsLabel.text = "Hello Teeks" /// TODO: Fix name
//        greetingsLabel.font = UIFont(name: "Avenir", size: 14)
//        greetingsLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//        greetingsLabel.anchor(top: dateLabel.bottomAnchor, left: view.leftAnchor, bottom: <#T##NSLayoutYAxisAnchor?#>, right: <#T##NSLayoutXAxisAnchor?#>, paddingTop: <#T##CGFloat#>, paddingLeft: <#T##CGFloat#>, paddingBottom: <#T##CGFloat#>, paddingRight: <#T##CGFloat#>, width: <#T##CGFloat?#>, height: <#T##CGFloat?#>)
//        
//        quotesLabel.text = "May 7, 2020" /// TODO: Fix date
//        quotesLabel.font = UIFont(name: "Avenir", size: 15)
//        quotesLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, height: 20)
//    }
//    
//    private func configureSegmentControlUI(){
//        //TODO: Update color
//                segment.backgroundColor = Constants.backgroundColor
//                segment.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
//    }
//    
//    private func configureBottomView(){
//        view.addSubview(bottomView)
//        bottomView.anchor(
//            left: view.leftAnchor,
//            bottom: view.bottomAnchor,
//            right: view.rightAnchor,
//            height: 80)
//        /// TODO: Change color
//        bottomView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
//    }
//    
//    private func configureActionButton(){
//        view.addSubview(actionButton)
//        actionButton.centerX(inView: view)
//        actionButton.centerX(inView: view, topAnchor: bottomView.firstBaselineAnchor, paddingTop: -30)
//        actionButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
//        actionButton.tintColor = .white
//        actionButton.anchor(
//            width: 60,
//            height: 60)
//        actionButton.layer.cornerRadius = 20
//        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
//    }
//    
//    private func configureContainerViews(){
//        
//        addChild(ongoingViewController)
//        view.addSubview(ongoingViewController.view)
//        ongoingViewController.delegate = self
//        ongoingViewController.view.anchor(
//            top: view.safeAreaLayoutGuide.topAnchor,
//            left: view.leftAnchor,
//            bottom: bottomView.topAnchor,
//            right: view.rightAnchor)
//        
//        addChild(doneViewController)
//        view.addSubview(doneViewController.view)
//        doneViewController.view.anchor(
//            top: view.safeAreaLayoutGuide.topAnchor,
//            left: view.leftAnchor,
//            bottom: bottomView.topAnchor,
//            right: view.rightAnchor)
//        
//        ongoingViewController.view.alpha = 1
//        doneViewController.view.alpha = 0
//        
//        /// layout subviews immedietly
//        ongoingViewController.view.layoutIfNeeded()
//        doneViewController.view.layoutIfNeeded()
//    }
//    
//    private func deleteTask(for id: String){
//        databaseManager.deleteTask(for: id) {[weak self] (result) in
//            guard let self = self else {return}
//            switch result{
//            case.failure(let error):
//                self.printDebug(message: "deleteTask: \(error.localizedDescription)")
//                self.showToast(state: .error, message: "Uh Oh, something went wrong.")
//            case.success:
//                self.showToast(state: .success, message: "Task has been deleted successfully.")
//            }
//        }
//    }
//}
//
//
////  MARK: Extensions
//extension TaskViewController: TaskVCDelegate {
//    
//    func didAddTask(for task: Task) {
//        presentedViewController?.dismiss(animated: true, completion: {[unowned self] in
//            
//            self.databaseManager.addTask(task) {[unowned self] (result) in
//                switch result{
//                case .success:
//                    self.showToast(state: .success, message: "New task added!")
//                    
//                case .failure(let error):
//                    printDebug(message: error.localizedDescription)
//                    self.showToast(state: .error, message: "Uh oh, something went wrong.")
//                }
//            }
//        })
//    }
//}
//
//
//extension TaskViewController: OngoingTasksTVCDelegate {
//    /// The parent view will act as the delegate for the child.
//    /// when a cell is selected in the child, the child will be notified ( need an intern to pass on information)
//    /// The parent will act as the intern , take the information and execiutes methods. 
//    func showOptions(for task: Task){
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//        let delete = UIAlertAction(title: "Delete", style: .destructive) {[unowned self] (_) in
//            /// use unowned self when we are confident that self will never be nil.
//            guard let id = task.id else {return}
//            self.deleteTask(for: id)
//        }
//        alert.addAction(cancel)
//        alert.addAction(delete)
//        present(alert, animated: true)
//    }
//    
//}
//
