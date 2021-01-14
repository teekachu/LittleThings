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
            showWelcomeLabel(for: user!.fullname)
            addTaskObserver()
        }
    }
    private var sidemenu: SideMenuNavigationController!
    private var stringToLoad = ""
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func additionalInfoTapped(_ sender: Any) {
        let msg = Constants.ruleOfThumb
        let controller = CustomAlertViewController(alertMessage: msg)
        present(a: controller)
    }
    
    @IBAction func ShowMenuTapped(_ sender: Any) {
        present(sidemenu, animated: true)
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
        present(a: controller)
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
            
            DispatchQueue.main.async { [weak self] in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
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
        actionButton.tintColor = Constants.whiteOffblack
        actionButton.setTitle("+ Add Task", for: .normal)
        actionButton.titleLabel?.font = UIFont(name: Constants.fontMedium, size: 16)
        actionButton.layer.cornerRadius = 12
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = Constants.lightGrayCDCDCD.cgColor
        actionButton.addTarget(self, action: #selector(didPressAddTaskButton), for: .touchUpInside)
    }
    
    private func configureSideMenu(){
        let sideMenuController = SideMenuTableViewController(delegate: self)
        sidemenu = SideMenuNavigationController(rootViewController: sideMenuController)
        sidemenu.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sidemenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
    }
    
    
    //  MARK: - Privates
    
    private func editTask(for task: Task){
        let controller = AddNewTaskViewController(taskManager: taskManager, task: task, isEditingTask: true)
        controller.delegate = self
        present(a: controller)
    }
    
    private func enterSwapMode(for task: Task){
        let controller = CustomTVViewController(for: task)
        controller.delegate = self
        present(a: controller)
    }
    
    private func didTapActionButton(for task: Task) {
        let currentDoneStatus = task.isDone
        taskManager.updateTaskStatus(task, isDone: !currentDoneStatus) {[weak self] (status, message) in
            self?.showToast(state: status, message: message)
        }
    }
    
    private func showWelcomeLabel(for name: String){
        greetingsLabel.text = "Hello \(name)"
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
    
    private func showAboutUsScreen(){
        let infoController = AboutUSViewController()
        present(a: infoController)
    }
    
    private func presentSwapScreen(for oldTask: Task?, with newText: String?){
        guard let oldTask = oldTask else {return}
        guard let newText = newText else {return}
        let controller = SwapTaskViewController(for: oldTask, with: newText)
        controller.delegate = self
        present(a: controller)
    }
    
    
    //  MARK: - User Defaults
    private func saveToUserDefaults(for task: Task, with newString: String){
        let defaults = UserDefaults.standard
        defaults.set(task.id, forKey: "savedTaskID")
        defaults.set(newString, forKey: "savedString")
    }
    
    private func checkSwap(onLoad: @escaping(Task?) -> Void) {
        let defaults = UserDefaults.standard
        if let taskID = defaults.string(forKey: "savedTaskID"){
            taskManager.getSingleTask(documentID: taskID) { (task) in
                onLoad(task)
            }
            onLoad(nil)
        }
    }
    
    
    // MARK: - Auth
    private func authenticateUser(){
        
        if Auth.auth().currentUser?.uid == nil{
            presentMainAuthVC()
            
        } else {
            checkSwap { (task) in
                guard let newString = UserDefaults.standard.string(forKey: "savedString") else {return}
                self.presentSwapScreen(for: task, with: newString)
            }
            updateUserToCurrentUser()
        }
    }
    
    private func presentMainAuthVC() {
        let controller = AuthMainViewController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(a: nav)
    }
    
    
    func updateUserToCurrentUser(){
        AuthManager.fetchUserFromFirestore { (user) in
            self.user = user
            print("DEBUG fetchUser(): User \(user.fullname) is currently logged in, uid is\(user.uid)")
        }
    }
}


//  MARK: - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selected = dataSource.itemIdentifier(for: indexPath){
            if selected.isDone == true {return}
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
    func showOptions(for task: Task){
        let controller = UIAlertController.addTask {[weak self] didSelectEdit in
            if didSelectEdit {
                self?.editTask(for: task)
            } else {
                self?.enterSwapMode(for: task)
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

//MARK: - CustomTextViewDelegate
extension TasksViewController: CustomTextViewDelegate {
    func presentSwapVC(for oldTask: Task?, with newText: String?) {
        dismiss(animated: true) {[weak self] in
            guard let oldTask = oldTask else {return}
            guard let newText = newText else {return}
            self?.presentSwapScreen(for: oldTask, with: newText)
            self?.saveToUserDefaults(for: oldTask, with: newText)
        }
    }
}

//MARK: - SwapTaskVCDelegate
extension TasksViewController: SwapTaskVCDelegate {
    func didSwapTask(for task: Task, with newTitle: String) {
        
        UserDefaults.standard.removeObject(forKey: "savedTaskID")
        UserDefaults.standard.removeObject(forKey: "savedString")
        
        dismiss(animated: true) {
            let uid = task.uid // user uid
            let type = task.taskType
            let newTask = Task(title: newTitle, isDone: false, taskType: type, uid: uid)
            self.taskManager.updateTaskStatus(task, isDone: true) {(state, message) in
                print("Debug toast msg: \(message)")
            }
            self.taskManager.store(newTask) {[weak self](state, message) in
                self?.showToast(state: state, message: message)
            }
        }
    }
}

//MARK: - SideMenuDelegate
extension TasksViewController: SideMenuDelegate {
    
    func sidemenu(didSelect option: MenuOption) {
        switch option {
        //        case .supportDevelopment:
        //            print("support devs")
        
        case .shareWithFriends:
            let items = [URL(string: "https://testflight.apple.com/join/FwtK8Ylo")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
            
        case .sendSuggestions:
            let emailAddress = "mailto:teeksbuildapps@outlook.com"
            guard let emailURL = URL(string: emailAddress) else { return }
            UIApplication.shared.open(emailURL,
                                      options: [:],
                                      completionHandler: nil)
            
        case .whatIs135:
            let infoController = AppInfoViewController()
            present(a: infoController)
            
        case .reportBug:
            /// Can probably get rid of this
            let emailAddress = "mailto:teeksbuildapps@outlook.com"
            guard let emailURL = URL(string: emailAddress) else { return }
            UIApplication.shared.open(emailURL,
                                      options: [:],
                                      completionHandler: nil)
            
        case .about:
            showAboutUsScreen()
            
        case .clearDone:
            
            let controller = UIAlertController.clearDoneTasks {[weak self] (didSelect) in
                if didSelect{
                    if let filtered = self?.tasks.filter({ $0.isDone}) {
                        self?.taskManager.deleteAll(tasks: filtered)
                    }
                } else {
                    self?.dismiss(animated: true)
                }
            }
            present(controller, animated: true)
            
        case .logOut:
            taskManager.emptyTasksBeforeLogOut()
            AuthManager.signUserOut()
            presentMainAuthVC()
            
        case .settings:
            let infoController = SettingsViewController(delegate: self)
            present(a: infoController)
        }
    }
}


//MARK: - SettingsMenuDelegate
extension TasksViewController: SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption) {
        switch option{
        
        case .changeName:
            
            let controller = UIAlertController.showAlertWithTextfield {[weak self] (newName, didTap) in
                if didTap{
                    
                    AuthManager.updateUserName(with: newName) { (err) in
                        if err != nil {
                            self?.showToast(state: .error, message: err?.localizedDescription ?? "Uh oh, something went wrong")
                            return
                        }
                        /// Refresh the name label in main page to show new name
                        self?.showWelcomeLabel(for: newName)
                    }
                    
                } else {
                    self?.dismiss(animated: true)
                }
            }
            
            ///Prefill with old name
            if let oldName = user?.fullname{
                controller.textFields?[0].text = oldName
            }
            
            present(controller, animated: true)
            
            
        //        case .Language:
        //            print("change language to chinese")
        
        case.exit:
            dismiss(animated: true)
        }
    }
}


