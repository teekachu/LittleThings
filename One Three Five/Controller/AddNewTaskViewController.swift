//
//  AddNewTaskViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/3/20.
//

import UIKit
import Combine
import Loaf

class AddNewTaskViewController: UIViewController {
    
    //  MARK: - Properties
    private let taskManager: TaskManager
    private var task: Task
    private let isEditingTask: Bool
    private let taskCharacterCount = 200
    
    @Published private var taskString: String? ///Observe this variable because this is what will be updated as we type into the textfield
    private var currentTasktype: TaskType = .one
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    weak var delegate: NewTaskVCDelegate?
    
    
    //  MARK: - IBProperties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var BottomContainerView: UIView!
    @IBOutlet weak var TaskTextfield: UITextField!
    @IBOutlet weak var descriptionCharCountLabel: UILabel! = {
        let lbl = UILabel()
        return lbl
    }()
    @IBOutlet weak var TaskPickerView: UIPickerView!
    @IBOutlet weak var errorMsgLabel: UILabel! = {
        let lbl = UILabel()
        lbl.textColor = Constants.brightOrange
        return lbl
    }()
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBAction func saveButtonTapped(_ sender: Any) {
        updateTask()
        guard taskString != nil else {
            showToast(state: .error, message: "Please enter a title")
            return
        }
        
        //        guard isAble(toAdd: task) else {
        //            return
        //        }
        
        if isEditingTask {
            /// update task with new info
            delegate?.didEditTask(for: task)
        } else {
            /// creating new task
            delegate?.didAddTask(for: task)
        }
    }
    
    init(taskManager: TaskManager, task: Task, isEditingTask: Bool = false) {
        self.taskManager = taskManager
        self.task = task
        self.isEditingTask = isEditingTask
        super.init(nibName: "AddNewTaskViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGesture()
        observeKeyboard()
        observeForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TaskTextfield.becomeFirstResponder()
        updateTask()
        //        isAble(toAdd: task)
    }
    
    
    //  MARK: - Selectors
    @objc func tapToDismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut) {[weak self] in
            self?.containerViewBottomConstraint.constant = keyboardHeight - 40
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        
        BottomContainerView.layer.cornerRadius = 35
        BottomContainerView.layer.borderWidth = 3
        BottomContainerView.layer.borderColor = Constants.bottomContainerBorder?.cgColor
        BottomContainerView.backgroundColor = UIColor(named: "viewbackgroundWhitesmoke")
        
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
        
        TaskTextfield.backgroundColor = .clear
        TaskTextfield.borderStyle = .none
        TaskTextfield.textColor =  Constants.blackWhite
        TaskTextfield.font = UIFont(name: Constants.fontMedium, size: 20)
    
        TaskPickerView.delegate = self
        TaskPickerView.dataSource = self
        TaskPickerView.backgroundColor = .clear
        TaskPickerView.layer.borderWidth = 1.7
        TaskPickerView.layer.borderColor = Constants.innerYellowFCD12A.cgColor
        TaskPickerView.layer.cornerRadius = 20
        
        saveButton.tintColor = Constants.blackWhite
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = UIFont(name: Constants.fontMedium, size: 19)
        
        TaskTextfield.text = task.title
        taskString = task.title
        currentTasktype = task.taskType
        switch currentTasktype {
        case .one:
            TaskPickerView.selectRow(0, inComponent: 0, animated: false)
        case.three:
            TaskPickerView.selectRow(1, inComponent: 0, animated: false)
        case.five:
            TaskPickerView.selectRow(2, inComponent: 0, animated: false)
        }
        let title = isEditingTask ? "Update" : "Save"
        saveButton.setTitle(title, for: .normal)
        /// update time  created to time updated
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func observeKeyboard(){
        /// to observe when the keyboard is available and push the bottom card up or down
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //  MARK: - Combine
    private func observeForm() {
        let notificationName = UITextField.textDidChangeNotification
        NotificationCenter.default.publisher(for: notificationName).map { (notification) -> String? in
            return (notification.object as? UITextField)?.text
        }.sink {[unowned self] (text) in
            self.taskString = text
        }.store(in: &subscribers)
        
        /// change button enable status based on taskString is empty or not
        $taskString.sink {[weak self] (text) in
            guard let self = self else { return }
            self.saveButton.isEnabled =
                text?.isEmpty == false &&
                text?.meetsCharCount(of: self.taskCharacterCount) == true
        }.store(in: &subscribers)
        
        /// monitor character count for textfield
        $taskString.sink {[weak self] (text) in
            guard let self = self else { return }
            guard let text = text else { return }
            self.descriptionCharCountLabel.alpha = self.updateAlphaPerCharCount(for: text)
            self.descriptionCharCountLabel.text = "- \(text.count - self.taskCharacterCount)"
        }.store(in: &subscribers)
    }
    
    private func updateTask() {
        task.title = taskString
        task.taskType = currentTasktype
    }
    
    private func updateAlphaPerCharCount(for text: String) -> CGFloat{
        if text.count < taskCharacterCount{
            return 0
        }
        return 1
    }
    
    private func enableButtonPerCharCount(for text: String) -> Bool {
        if text.count < taskCharacterCount{
            return true
        }
        return false
    }

    //    @discardableResult private func isAble(toAdd task: Task) -> Bool {
    //
    //        /// 135 - Make sure user doesn't add more than 9 tasks or more than 1/1, 3/3, 5/5
    //        let errorText = taskManager.currentTasktypeMeetsRestriction(for: task)
    //
    //        if errorText != nil {
    //            errorMsgLabel.text = errorText
    //            errorMsgLabel.textColor = .red
    //            /// otherwise continue
    //            print("Did not have 9 tasks, continue")
    //            return false
    //        } else {
    //            errorMsgLabel.text = "One little thing at a time."
    //            errorMsgLabel.textColor = Constants.orangeTintColorFDB903
    //        }
    //
    //        return true
    //    }
}


//  MARK: - UIGestureRecognizerDelegate
extension AddNewTaskViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if BottomContainerView.isDescendant(of: view){
            if touch.view?.isDescendant(of: BottomContainerView) == false{
                /// touch anywhere else thats not bottomContainer to dismiss bottomContainerView
                dismiss(animated: true)
            }
            return false
        }
        return true
    }
}


//  MARK: - UIPickerViewDelegate
extension AddNewTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource, Animatable{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TaskType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let textColor = Constants.blackYellow
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: Constants.fontMedium, size: 18)
            pickerLabel?.textAlignment = .center
            pickerLabel?.backgroundColor = Constants.pickerLabelBackground
        }
        pickerLabel?.text = TaskType.allCases[row].rawValue
        pickerLabel?.textColor = textColor
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            currentTasktype = .one
        case 1:
            currentTasktype = .three
        case 2:
            currentTasktype = .five
        default:
            break
        }
        
        updateTask()
        //        isAble(toAdd: task)
    }
}

