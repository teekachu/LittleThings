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
    private let taskManager: TaskManager
    weak var delegate: OngoingTasksTVCDelegate?
    
    let cellID = "cell"
    private var tableView: UITableView!
    private var datasource: DataSource! /// enum created
    
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskObserver() /// Pulls tasks from firebase
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
    private func addTaskObserver() {
        taskManager.setTaskObserver { [weak self] tasks in
            print("✅ tasks", tasks)
            self?.configureSnapshot(for: tasks)
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
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
        taskManager.update(task) { [weak self] (status, message) in
            self?.showToast(state: status, message: message)
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
