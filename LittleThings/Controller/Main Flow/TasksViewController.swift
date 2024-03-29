//
//  TasksViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Loaf

protocol TasksViewControllerDelegate: class {
    func showOptions(for task: Task)
}

class TasksViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    
    private let authManager: AuthManager
    private let taskManager: TaskManager
    private let notificationsManager: NotificationsManager
    private let databaseManager: DatabaseManager
    private var dataSource: DataSource!
    private var isDoneActive: Bool = false {
        didSet {
            tasks = tasks + []
        }
    }
    private var tasks: [Task] = [] {
        didSet {
            // filter things
            configureSnapshot(for: tasks.filter { $0.isDone == isDoneActive})
            
            // reload tableview on main thread
            DispatchQueue.main.async {[weak self] in self?.tableView.reloadData()}
            
            // Update badge count
            if user?.uid != nil {
                databaseManager.getBadgeCount(for: user!.uid) {[weak self] (count) in
                    self?.notificationsManager.setBadge(to: count)
                }
            }
        }
    }
    private var user: User? {
        didSet{
            showUserName(for: user!.fullname)
            addTaskObserver()
        }
    }
    private var allQuotes = [Quote]()
    private var needMotivation: Bool = false
    
    //  MARK: - IB Properties
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func additionalInfoTapped(_ sender: Any) {
        let msg = Constants.ruleOfThumb
        let controller = CustomAlertViewController(alertTitle: "Rule Of Thumb:", alertMessage: msg)
        present(a: controller)
    }
    @IBAction func ShowMenuTapped(_ sender: Any) {
        let menuVC = SettingsViewController(delegate: self, databaseManager: databaseManager, authManager: authManager, notificationManager: notificationsManager)
        menuVC.delegate2 = self
        present(menuVC, animated: true)
    }
    @IBAction func nameLabelTapped(_ sender: Any) {
        handleNameChange()
    }
    
    //  MARK: - Lifecycle
    init(authManager: AuthManager,
         taskManager: TaskManager,
         notificationsManager: NotificationsManager,
         databaseManager: DatabaseManager) {
        
        self.authManager = authManager
        self.taskManager = taskManager
        self.notificationsManager = notificationsManager
        self.databaseManager = databaseManager
        super.init(nibName: "TasksViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        configureTableView()
        configureDataSource()
        addTaskObserver()
        configureUI()
        segment.addTarget(self, action: #selector(segmentedControl(_:)), for: .valueChanged)
        makeNetworkCallToParseQuotesInJson()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
    
    //  MARK: - Selectors
    @objc func segmentedControl(_ sender: UISegmentedControl) {
        isDoneActive = sender.selectedSegmentIndex != 0
        isDoneActive ? actionButton.setImage(UIImage(systemName: "trash"), for: .normal)
            : actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    
    @objc func didPressAddTaskButton() {
        Action.createHapticFeedback(style: .light)
        if isDoneActive {
            clearAllDoneTasks()
        } else {
            guard let userID = authManager.userID else { return }
            let controller = AddNewTaskViewController(taskManager: taskManager, task: .basic(for: userID))
            controller.delegate = self
            controller.delegate2 = self
            present(a: controller)
        }
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
        
        nameButton.alpha = 0
        nameButton.backgroundColor = .clear
        nameButton.setImage(UIImage(systemName: "sparkles"), for: .normal)
        nameButton.semanticContentAttribute = .forceRightToLeft
        nameButton.tintColor = Constants.orangeFDB903
        nameButton.setTitle(" ", for: .normal)
        nameButton.setTitleColor(Constants.smallTextNavBarColor, for: .normal)
        nameButton.titleLabel?.font = UIFont(name: Constants.fontBoldItalic, size: 19)
        
        if !needMotivation {
            quotesLabel.text = ""
            quotesLabel.isHidden = true
        }
        quotesLabel.numberOfLines = 0
        quotesLabel.textColor = Constants.normalBlackWhite
        
        actionButton.backgroundColor = Constants.orangeFDB903
        actionButton.tintColor = .black
        actionButton.setImage(UIImage(systemName: isDoneActive ? "trash" : "plus"), for: .normal)
        actionButton.layer.cornerRadius = 20
        actionButton.addTarget(self, action: #selector(didPressAddTaskButton), for: .touchUpInside)
    }
    
    //  MARK: - Privates
    private func editTask(for task: Task){
        let controller = AddNewTaskViewController(taskManager: taskManager, task: task, isEditingTask: true)
        controller.delegate = self
        controller.delegate2 = self
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
    
    private func showUserName(for name: String){
        nameButton.setTitle("Hello \(name) ", for: .normal)
        nameButton.titleLabel?.numberOfLines = 1
        nameButton.titleLabel?.textAlignment = .left
        UIView.animate(withDuration: 0.9) {[weak self] in
            self?.nameButton.alpha = 1
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
    
    private func handleNameChange(){
        Action.createHapticFeedback(style: .light)
        let controller = UIAlertController.showAlertWithTextfield {[weak self] (newName, didTap) in
            guard newName.count < 20 &&
                    newName.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {return}
            if didTap{
                
                self?.authManager.updateUserName(with: newName) { (err) in
                    if err != nil {
                        self?.showToast(state: .error, message: err?.localizedDescription ?? "Uh oh, something went wrong")
                        return
                    }
                    /// Refresh the name label in main page to show new name
                    self?.showUserName(for: newName)
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
    }
    
    private func clearAllDoneTasks(){
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
    }
    
    //  MARK: - JSON Parsing
    private func makeNetworkCallToParseQuotesInJson(){
        let urlString = "https://gist.githubusercontent.com/teekachu/17d8ffa168ef32f3138aef671050f60d/raw/e3c6895ce42069f0ee7e991229064f167fe8ccdc/quotes.json"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.global(qos: .userInteractive).async {[weak self] in
                    self?.parse(json: data)
                }
            }
        }
    }
    
    private func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonQuotes = try? decoder.decode(Quotes.self, from: json) {
            allQuotes = jsonQuotes.quotes
        }
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
        if !authManager.isUserLoggedIn {
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
        let controller = AuthMainViewController(authManager: authManager)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(a: nav)
    }
    
    
    func updateUserToCurrentUser(){
        authManager.fetchUserFromFirestore { [weak self] (user) in
            self?.user = user
            self?.notificationsManager.publishCurrentToken()
            self?.databaseManager.notifyUserDidAuthSuccessfully(userID: user.uid)
            print("DEBUG fetchUser(): User \(user.fullname) is currently logged in, uid is \(user.uid)")
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


// //  MARK: - MotivationQuoteDelegate
extension TasksViewController: MotivationQuoteDelegate{
    func needMotivation(_ option: Bool) {
        needMotivation = option

        if !allQuotes.isEmpty && needMotivation {
            if let chosenQuote = allQuotes.randomElement() {
                quotesLabel.isHidden = false
                quotesLabel.text = "\(chosenQuote.quote) - \(chosenQuote.author)"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {[weak self] in
            self?.needMotivation = false
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
                self?.quotesLabel.isHidden = true
            } completion: { (_) in
                self?.quotesLabel.text = ""
                UserDefaults().setValue(false, forKey: "showMotivation")
            }
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

extension TasksViewController: AddNewTaskVCDelegate {
    func numberOfExistingTasks(of type: TaskType) -> Int {
        let count = tasks.filter{$0.taskType == type && $0.isDone == false}.count
        return count
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
        
        authManager.updateUserHasSeenOnboardingInDatabase {[weak self] (error) in
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
    func presentFocusVC(for oldTask: Task?, with newText: String?) {
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
        dismiss(animated: true) {
            let uid = task.uid // user uid
            let type = task.taskType
            let newTask = Task(title: newTitle, isDone: false, taskType: type, uid: uid)
            
            self.taskManager.updateTaskStatus(task, isDone: true) { (state, message) in
                print("Debug toast msg: \(message)")
            }
            
            self.taskManager.store(newTask) {[weak self] (state, message) in
                self?.showToast(state: state, message: message)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "savedTaskID")
        UserDefaults.standard.removeObject(forKey: "savedString")
    }
}


//MARK: - SettingsMenuDelegate
extension TasksViewController: SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption) {
        switch option{
        
        case .whatIs135:
            let infoController = AppInfoViewController()
            present(a: infoController)
            
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

        case .about:
            showAboutUsScreen()
            
        case .privacyPolicy:
            guard let privacyURL = URL(string: "https://littlethings-1-3-5.flycricket.io/privacy.html") else {return}
            UIApplication.shared.open(privacyURL, options: [:], completionHandler: nil)
            
        case .termsCondition:
            guard let termsURL = URL(string: "https://littlethings-1-3-5.flycricket.io/terms.html") else {return}
            UIApplication.shared.open(termsURL, options: [:], completionHandler: nil)
            
        case .logOut:
            //present alert controller , if yes, do below . else exit
            let logoutAlert = UIAlertController.showLogOutAlert {[weak self] (didSelectLogout) in
                if didSelectLogout {
                    guard let self = self else {return}
                    self.taskManager.emptyTasksBeforeLogOut()
                    self.authManager.signUserOut()
                    self.presentMainAuthVC()
                }
            }
            
            present(logoutAlert, animated: true)
        }
    }
}


