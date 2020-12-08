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
    }
    
    //  MARK: Selectors
    
    
    //  MARK: Privates
    private func configureTableView(){
        let tableView = UITableView()
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

