//
//  OngoingTableViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf

class OngoingTableViewController: UIViewController {
    
    //  MARK: Properties
    weak var delegate: OngoingTasksTVCDelegate?
    
    let cellID = "cell"
    /// Master list of all Task
    public var tasks: [Task] = []
    {
        didSet{
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private var tableView: UITableView!
    private var datasource: DataSource! /// enum created
    private let databaseManager = DatabaseManager()
    
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTasksListener() /// Pulls tasks from firebase
        configureTableView()
        configureDataSource()
//        bridgeToAddNewTaskVC() ///135
    }
    
    //  MARK: Selectors
    
    
    //  MARK: Privates
    private func configureTableView(){
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "OngoingTaskTableViewCell", bundle: nil),
            forCellReuseIdentifier: cellID
        )
        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        tableView.separatorColor = .clear
        tableView.backgroundColor = Constants.viewBackgroundWhiteSmoke
        self.tableView = tableView
    }
    
    /// Pulls task through using the databaseManager
    private func addTasksListener(){
        databaseManager.addTaskListener(forDoneTasks: false) {[weak self] (result) in
            guard let self = self else{return}
            switch result{
            case .failure(let error):
                self.printDebug(message: "addTaskListener: \(error.localizedDescription)")
                
            case .success(let decodedTasks):
                self.tasks = decodedTasks
                self.configureSnapshot(for: self.tasks)
            }
        }
    }
    
    private func configureDataSource(){
        datasource = DataSource(tableView: tableView, cellProvider: {[weak self] (tableview, indexpath, task) -> UITableViewCell? in
            
            guard let cell = self?.tableView.dequeueReusableCell(withIdentifier: self!.cellID, for: indexpath) as? OngoingTaskTableViewCell else{
                fatalError("Unable to dequeue")
            }
            /// To update the done status of the task
            cell.actionButtonDidTap = {[weak self] in
                self?.handleActionButton(for: task)
            }
            cell.configureTaskCell(with: task)
            cell.layer.borderWidth = 1.3
            cell.layer.borderColor = Constants.cellBorderColor?.cgColor
            return cell
        })
        
        /// set up type of animation
        datasource.defaultRowAnimation = .fade
    }
    
    private func configureSnapshot(for stored: [Task]){
        /// set up initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<TaskType, Task>()
        
        /// populate snapshot with sections and items for each section
        /// Case iterable allows iterating through all cases
        
        for type in TaskType.allCases {
            /// filter  [tasks] array items for particular tasktype item
            let filteredTasks = stored.filter{
                $0.taskType == type
            }
            
            snapshot.appendSections([type]) /// add section to table
            snapshot.appendItems(filteredTasks, toSection: type)
        }
        
        DispatchQueue.main.async {
            self.datasource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func handleActionButton(for task: Task) {
        guard let id = task.id else { return }
        /// update in databasemanager to done.
        databaseManager.updateTaskStatus(for: id, isDone: true) {[weak self] (result) in
            guard let self = self else {return}
            switch result {
            
            case .failure(let error):
                self.showToast(state: .error, message: toastMessages.uhOhErr)
                self.printDebug(message: error.localizedDescription)
                
            case .success:
                /// Using the protocol / extension
                self.showToast(state: .success, message: "Moved task to done. Good Job!!!")
            }
        }
    }
    
//    private func bridgeToAddNewTaskVC(){
//        let avc = AddNewTaskViewController()
//        avc.delegate2 = self
//    }
}


//  MARK: Extensions
extension OngoingTableViewController: UITableViewDelegate, Animatable {
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selected = datasource.itemIdentifier(for: indexPath){
            delegate?.showOptions(for: selected)
        }
    }
}

///135
extension OngoingTableViewController: OngoingTasksDelegate {
    
    func currentTasktypeMeetsRestriction(for task: Task, completion: @escaping ((String?) -> Void)) {
        
        /// basically determine whether the user is adding too many tasks or not.
        
        let typeOne = tasks.filter{ $0.taskType == .one }
        let typeThree = tasks.filter{ $0.taskType == .three }
        let typeFive = tasks.filter{ $0.taskType == .five }
        
        if typeOne.count == 1
            && typeThree.count == 3
            && typeFive.count == 5 {
            completion("Currently have 9 tasks ongoing already")
        } else {
            if task.taskType == .one && typeOne.count == 1 {
                completion("Already have 1 large task")
            } else if task.taskType == .three && typeThree.count == 3 {
                completion("Already have 3 medium tasks")
            } else if task.taskType == .five && typeFive.count == 5 {
                completion("Already have 5 small tasks")
            }
        }
        
        completion(nil)
    }
}

