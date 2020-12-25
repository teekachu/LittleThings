//
//  TasksViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf
import Firebase
import SideMenu

protocol TasksViewControllerDelegate: class {
    func showOptions(for task: Task)
}

class TasksViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    private let taskManager: TaskManager
    private var dataSource: DataSource!
    private var isDoneActive: Bool = false {
        didSet { tasks = tasks + [] }
    }
    private var tasks: [Task] = [] {
        didSet {
            configureSnapshot(for: tasks.filter { $0.isDone == isDoneActive})
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private var user: User? {
        didSet{
            showWelcomeLabel()
            addTaskObserver()
        }
    }
    
    private var sidemenu: SideMenuNavigationController!
    
    //  MARK: - IB Properties
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func InfoButtonTapped(_ sender: Any) {
        let infoController = AppInfoViewController()
        infoController.modalPresentationStyle = .overCurrentContext
        infoController.modalTransitionStyle = .crossDissolve
        present(infoController, animated: true)
    }
    @IBAction func calendarButtonTapped(_ sender: Any) {
        print("Show me calendar view.")
    }
    @IBAction func ShowMenuTapped(_ sender: Any) {
        present(sidemenu, animated: true)
        
        // shows the log out & clear all alert
        //        handleMenuOptions()
    }
    
    
    //  MARK: - Lifecycle
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        super.init(nibName: "TasksViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sideMenuController = SideMenuTableViewController(delegate: self)
        sidemenu = SideMenuNavigationController(rootViewController: sideMenuController)
        authenticateUser()
        configureTableView()
        configureDataSource()
        addTaskObserver()
        configureUI()
        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
        configureSideMenu()
    }
    
    //  MARK: - Selectors
    @objc func segmentedControl(_ sender: UISegmentedControl) {
        isDoneActive = sender.selectedSegmentIndex != 0
    }
    
    @objc func didPressAddTaskButton() {
        let controller = AddNewTaskViewController(taskManager: taskManager, task: .basic)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }
    
    
    //  MARK: - Configuration Setup
    private func configureTableView() {
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = Constants.viewBackgroundWhiteSmoke
        tableView.registerCell(.ongoing)
        tableView.registerCell(.done)
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
    
    /// Pulls task through using the databaseManager
    private func addTaskObserver() {
        taskManager.setTaskObserver { [weak self] tasks in
            self?.tasks = tasks
        }
    }
    
    private func configureUI(){
        /// white in lightmode, med black in darkmode
        view.backgroundColor = Constants.navBarColor
        navigationController?.navigationBar.isHidden = true
        
        segment.backgroundColor = Constants.segmentBarBackground
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Constants.blackBlack ?? #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1),
                                        NSAttributedString.Key.font: UIFont(name: Constants.fontMedium, size: 16)!]
                                       ,for: UIControl.State.normal)
        
        dateLabel.text = Date().convertToString()
        dateLabel.textColor = Constants.smallTextNavBarColor
        
        /// TODO: Update label text
        greetingsLabel.alpha = 0
        greetingsLabel.text = " "
        greetingsLabel.textColor = Constants.smallTextNavBarColor
        greetingsLabel.font = UIFont(name: Constants.fontBoldItalic, size: 19)
        
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
    
    private func configureSideMenu(){
        sidemenu.leftSide = true
        sidemenu.delegate = self
        SideMenuManager.default.leftMenuNavigationController = sidemenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
    }
    
    
    //  MARK: - Privates
    private func deleteTask(_ task: Task){
        taskManager.delete(task) {[weak self] (status, message) in
            guard let self = self else { return }
            self.showToast(state: status, message: message)
        }
    }
    
    private func editTask(for task: Task){
        guard task.isDone != true else {
            showToast(state: .error,
                      message: "This task has already been done. Please move it to ongoing if you are still working on it. ",
                      location: .top, duration: 2)
            return }
        
        /// open new task vc to edit
        let controller = AddNewTaskViewController(taskManager: taskManager, task: task, isEditingTask: true)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }
    
    private func didTapActionButton(for task: Task) {
        let currentDoneStatus = task.isDone
        taskManager.updateTaskStatus(task, isDone: !currentDoneStatus) {[weak self] (status, message) in
            self?.showToast(state: status, message: message)
        }
    }
    
    private func showWelcomeLabel(){
        guard let user = user else {
            print("Cannot fetch user in showWelcomeLabel")
            return }
        
        greetingsLabel.text = "Hello \(user.fullname)"
        greetingsLabel.numberOfLines = 1
        greetingsLabel.textAlignment = .left
        UIView.animate(withDuration: 0.9) {[weak self] in
            self?.greetingsLabel.alpha = 1
        }
    }
    
    private func presentOnboardingIfNecessary() {
        
        guard let user = user else {return}
        print("User has seen onboarding page status: \(user.hasSeenOnboardingPage)")
        
        if !user.hasSeenOnboardingPage {
            let cont = OnboardingViewController()
            cont.delegate = self
            cont.modalPresentationStyle = .fullScreen
            self.present(cont, animated: true)
        }
    }
    
    // MARK: - Auth
    private func handleMenuOptions(){
        let ac = UIAlertController.logUserOut {[weak self] (didSelectLogOut) in
            if didSelectLogOut{
                self?.taskManager.emptyTasksBeforeLogOut()
                AuthManager.signUserOut()
                self?.presentLoginVC()
            } else {
                /// Once implemented calender button , This function will no longer be needed 
                if let filtered = self?.tasks.filter({ $0.isDone}){
                    self?.taskManager.deleteAll(tasks: filtered)
                }
            }
        }
        present(ac, animated: true)
    }
    
    private func authenticateUser(){
        
        if Auth.auth().currentUser?.uid == nil{
            presentLoginVC()
        } else {
            updateUserToCurrentUser()
        }
    }
    
    private func presentLoginVC() {
        DispatchQueue.main.async {[weak self] in
            let controller = LoginViewController()
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true)
        }
    }
    
    
    func updateUserToCurrentUser(){
        AuthManager.fetchUserFromFirestore { (user) in
            self.user = user
            print("DEBUG fetchUser(): User \(user.fullname) is currently logged in, uid is\(user.uid)")
        }
    }
}

// MARK: - SideMenuDelegate
extension TasksViewController: SideMenuDelegate {
    func sideMenu(didSelect option: MenuOption) {
        print("option: ", option)
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
extension TasksViewController: TasksViewControllerDelegate {
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

//  MARK: - OnboardingControllerDelegate
extension TasksViewController: OnboardingControllerDelegate {
    func controllerWantsToDismiss(_ controller: OnboardingViewController) {
        dismiss(animated: true)
        
        AuthManager.updateUserHasSeenOnboardingInDatabase {[weak self] (error) in
            if let error = error {
                print("Error in controllerWantsToDismiss() \(error.localizedDescription)")
                return
            }
            self?.user?.hasSeenOnboardingPage = true
        }
    }
}

//  MARK: - AuthenticationDelegate
extension TasksViewController: AuthenticationDelegate {
    func authenticationComplete() {
        updateUserToCurrentUser()
        
        dismiss(animated: true) {[weak self] in
            self?.presentOnboardingIfNecessary()
        }
    }
}

 //MARK: - MenuControllerDelegate OR is it  UINavigationControllerDelegate

extension TasksViewController: UINavigationControllerDelegate {
    
    func handleMenuToggle(for menuOption: MenuOption?) {
        switch menuOption {
        case .supportDevelopment:
            print("support devs")
        case .some(.shareWithFriends):
            print("share")
        case .some(.sendSuggestions):
            print("send suggestions")
//        case .some(.contactDeveloper):
//            print("contact somebody")
        case .some(.whatIs135):
            print("show 1-3-5 detail page")
        case .some(.reportBug):
            print("report bug via email")
//        case .some(.privacyPolicy):
//            print("show privacy policy")
//        case .some(.termsCondition):
//            print("show terms and conditions")
        case .some(.about):
            print("show about us page")
        case .some(.clearDone):
            print("clear all in done for the day")
        case .some(.logOut):
            print("log me outta here")
        case .none:
            break
        }

    }
}
