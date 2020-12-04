//
//  OngoingTableViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf

class OngoingTableViewController: UIViewController, Animatable {
    
    //  MARK: Properties
    let cellID = "cell"
    var tasks: [Task] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    private var tableView: UITableView!
    private let databaseManager = DatabaseManager()
    
    
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addTasksListener() /// Pulls tasks from firebase
    }
    
    /// might not need this as included in didSet
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        tableView.reloadData()
    //    }
    
    
    //  MARK: Selectors
    
    
    //  MARK: Privates
    private func configureUI(){
        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
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
                self?.printDebug(message: error.localizedDescription)
            case .success(let decodedTasks):
                self?.tasks = decodedTasks
            }
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
extension OngoingTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? OngoingTaskTableViewCell else{
            fatalError("Unable to dequeue")
        }
        let eachtask = tasks[indexPath.row]
        /// To update the done status of the task
        cell.actionButtonDidTap = {[weak self] in
            self?.handleActionButton(for: eachtask)
        }
        cell.configureTaskCell(with: eachtask)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        let task = tasks[indexPath.row]
        //        delegate?.showTaskOptions(for: task)
    }
}
