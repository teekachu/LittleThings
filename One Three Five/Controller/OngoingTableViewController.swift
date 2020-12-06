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
    let cellID = "cell"
    /// Master list of all Task.
    /// This is an array of array where it should contain 1-3 arrays based on the type of tasks.
    var tasks: [Task] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    private var tableView: UITableView!
    private var datasource: DataSource! /// enum created
    private let databaseManager = DatabaseManager()
    
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        addTasksListener() /// Pulls tasks from firebase
        configureDataSource()
    }
    
    /// might not need this as included in didSet
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        tableView.reloadData()
    //    }
    
    //  MARK: Selectors
    
    
    //  MARK: Privates
    private func configureTableView(){
        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        //        tableView.dataSource = self
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
        databaseManager.addTaskListender(forDoneTasks: false) {[weak self] (result) in
            switch result{
            case .failure(let error):
                self?.printDebug(message: "addTaskListener: \(error.localizedDescription)")
            case .success(let decodedTasks):
                self?.tasks = decodedTasks
            }
        }
    }
    
    private func configureDataSource(){
        datasource = DataSource(tableView: tableView, cellProvider: {[weak self] (tableview, indexpath, task) -> UITableViewCell? in
            
            guard let cell = self?.tableView.dequeueReusableCell(withIdentifier: self!.cellID, for: indexpath) as? OngoingTaskTableViewCell else{
                fatalError("Unable to dequeue")
            }
            cell.configureTaskCell(with: task)
            return cell
        })
        /// set up type of animation
        datasource.defaultRowAnimation = .fade
        
        /// set up initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<TaskType, Task>()
        
        /// populate snapshot with sections and items for each section
        /// Case iterable allows iterating through all cases
        for type in TaskType.allCases {
            /// filter  [tasks] array items for particular tasktype item
            
            let task = self.tasks.filter{
                $0.taskType == type
            }
                
            /// Example code below using Testdata in Task.swift file
//            let task = Task.testData().filter {
//                $0.taskType == type
//            }
            snapshot.appendSections([type]) /// add section to table
            snapshot.appendItems(task)
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
                self.showToast(state: .error, message: toastMessages.uhOhErr, location: .top, duration: 2)
                self.printDebug(message: error.localizedDescription)
                
            case .success:
                /// Using the protocol / extension
                self.showToast(state: .success, message: "Moved task to done. Good Job!!!", duration: 1.5)
            }
        }
    }
}


//  MARK: Extensions
extension OngoingTableViewController: UITableViewDelegate, Animatable {
    //    // MARK: - Table view data source
    //
    //    /// 3 different sections for each type of task
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return tasks.count
    //    }
    //
    //    /// TODO: customize this
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let sectionHeaderTitleArray =
    //            ["One large task",
    //             "Three medium tasks",
    //             "Five small tasks"]
    //        let label = UILabel()
    //        label.text = sectionHeaderTitleArray[section]
    //        label.font = UIFont(name: "Avenir", size: 23)
    //        label.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    //        label.textColor = .white
    //        return label
    //    }
    //
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return tasks[section].count
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? OngoingTaskTableViewCell else{
    //            fatalError("Unable to dequeue")
    //        }
    //        let eachtask = tasks[indexPath.section][indexPath.row]
    //
    //        /// To update the done status of the task
    //        cell.actionButtonDidTap = {[weak self] in
    //            self?.handleActionButton(for: eachtask)
    //        }
    //        cell.configureTaskCell(with: eachtask)
    //        return cell
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        tableView.deselectRow(at: indexPath, animated: true)
    //        //        let task = tasks[indexPath.row]
    //        //        delegate?.showTaskOptions(for: task)
    //    }
}
