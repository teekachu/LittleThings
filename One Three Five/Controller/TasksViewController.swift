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
    private let taskManager: TaskManager
    private var dataSource: DataSource!
    private var isDoneActive: Bool = false {
        didSet {
            tasks = tasks + []
        }
    }
    private var tasks: [Task] = [] {
        didSet {
            configureSnapshot(for: tasks.filter { $0.isDone == isDoneActive})
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    //  MARK: IB Properties
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //  MARK: Lifecycle
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        super.init(nibName: "TasksViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = Constants.viewBackgroundWhiteSmoke
        tableView.registerCell(.ongoing)
        tableView.registerCell(.done)
        configureDataSource()
        addTaskObserver()
        
        configureUI()
        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
        
//        presentOnboardingController()
    }
    
    //  MARK: Selectors
    @objc func segmentedControl(_ sender: UISegmentedControl){
        isDoneActive = sender.selectedSegmentIndex != 0
    }
    
    @objc func didPressAddTaskButton() {
        let controller = AddNewTaskViewController(taskManager: taskManager, task: .basic)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
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
        actionButton.addTarget(self, action: #selector(didPressAddTaskButton), for: .touchUpInside)
    }
    
    //  MARK: Privates methods
    private func deleteTask(_ task: Task){
        taskManager.delete(task) {[weak self] (status, message) in
            guard let self = self else {return}
            self.showToast(state: status, message: message)
        }
    }
    
    private func editTask(for task: Task){
        /// open new task vc to edit
        let controller = AddNewTaskViewController(taskManager: taskManager, task: task, isEditingTask: true)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }
    
    private func presentOnboardingController(){
        let cont = OnboardingViewController()
        cont.modalPresentationStyle = .fullScreen
        present(cont, animated: true)
    }
    
    /// Pulls task through using the databaseManager
    private func addTaskObserver() {
        taskManager.setTaskObserver { [weak self] tasks in
            self?.tasks = tasks
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { [weak self] (tableview, indexpath, task) -> UITableViewCell? in
            let identifier = self!.isDoneActive ? "DoneTaskTableViewCell" :  "OngoingTaskTableViewCell"
            let cell = self!.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexpath)
            cell.layer.borderWidth = 1.3
            cell.layer.borderColor = Constants.cellBorderColor?.cgColor
            (cell as! Taskable).configureTaskCell(with: task)
            (cell as! Taskable).setTapObserver { [weak self] in
                self?.didTapActionButton(for: task)
            }
            return cell
        })
        
        /// set up type of animation
        dataSource.defaultRowAnimation = .fade
    }
    
    private func configureSnapshot(for stored: [Task]) {
        /// set up initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<TaskType, Task>()

        /// populate snapshot with sections and items for each section
        /// Case iterable allows iterating through all cases

        for type in TaskType.allCases {
            /// filter  [tasks] array items for particular tasktype item
            let filteredTasks = stored.filter {
                $0.taskType == type
            }

            snapshot.appendSections([type]) /// add section to table
            snapshot.appendItems(filteredTasks, toSection: type)
        }

        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func didTapActionButton(for task: Task) {
        let currentDoneStatus = task.isDone
        taskManager.updateTaskStatus(task, isDone: !currentDoneStatus) {[weak self] (status, message) in
            self?.showToast(state: status, message: message)
        }
    }
}

//  MARK: - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selected = dataSource.itemIdentifier(for: indexPath){
            showOptions(for: selected)
        }
    }
}

//  MARK: - NewTaskVCDelegate
extension TasksViewController: NewTaskVCDelegate {
    
    func didAddTask(for task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {[weak self] in
            self?.taskManager.store(task) {[weak self] (status, message) in
                self?.showToast(state: status, message: message)
            }
        })
    }
    
    func didEditTask(for task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {[weak self] in
            self?.taskManager.edit(task: task, onResult: { (status, message) in
                self?.showToast(state: status, message: message)
            })
        })
    }
}

//  MARK: - OngoingTasksTVCDelegate
extension TasksViewController: OngoingTasksTVCDelegate {
    /// The parent view will act as the delegate for the child.
    /// when a cell is selected in the child, the child will be notified ( need an intern to pass on information)
    /// The parent will act as the intern , take the information and execiutes methods.
    func showOptions(for task: Task){
        let controller = UIAlertController.addTask { didSelectEdit in
            if didSelectEdit {
                self.editTask(for: task)
            } else {
                self.deleteTask(task)
            }
        }
        present(controller, animated: true)
    }
}

