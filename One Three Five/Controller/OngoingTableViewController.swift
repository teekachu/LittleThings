//
//  OngoingTableViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class OngoingTableViewController: UIViewController {
    
    private var tableView: UITableView!
    private let databaseManager = DatabaseManager()
    
    //  MARK: Properties
    let cellID = "cell"
    var tasks: [Task] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    
    
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
        databaseManager.addTaskListender {[weak self] (result) in
            switch result{
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let decodedTasks):
                self?.tasks = decodedTasks
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
        cell.configureTaskCell(with: eachtask)
        return cell
    }
}
