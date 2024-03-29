//
//  AddNewTaskViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/3/20.
//

import UIKit
import Combine
import Loaf

protocol NewTaskVCDelegate: class {
    func didAddTask(for task: Task)
    func didEditTask(for task: Task)
}

protocol  AddNewTaskVCDelegate: class {
    func numberOfExistingTasks(of type: TaskType) -> Int
}

class AddNewTaskViewController: UIViewController, Animatable {
    //  MARK: - Properties
    private let taskManager: TaskManager
    private var task: Task
    private let isEditingTask: Bool
    
    ///Observe this below variables
    @Published private var taskString: String?
    private var currentTasktype: TaskType = .five
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    weak var delegate: NewTaskVCDelegate?
    weak var delegate2: AddNewTaskVCDelegate?
    
    //  MARK: - IBProperties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var BottomContainerView: UIView!
    @IBOutlet weak var OuuLabel: UILabel!
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel! = {
        let lbl = UILabel()
        return lbl
    }()
    @IBOutlet weak var TaskPickerView: UIPickerView!
    @IBOutlet weak var errorMsgLabel: UILabel! = {
        let lbl = UILabel()
        lbl.textColor = Constants.orangeFDB903
        return lbl
    }()
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var currentTaskCountLabel: UILabel!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBAction func saveButtonTapped(_ sender: Any) {
        updateTask()
        
        if isEditingTask {
            delegate?.didEditTask(for: task)
        } else {
            guard isAble(toAdd: task) else { return }
            delegate?.didAddTask(for: task)
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        textTextView.becomeFirstResponder()
        updateTask()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        BottomContainerView.layer.borderColor = Constants.bottomContainerBorder?.cgColor
        textTextView.layer.borderColor = Constants.orangeFDB903?.cgColor
    }
    
    
    //  MARK: - Selectors
    @objc func swipeToDismissKeybord(){
        textTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut) {[weak self] in
            self?.view.frame.origin.y = -keyboardHeight + 10
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemUltraThinMaterial)
        
        BottomContainerView.layer.cornerRadius = 35
        BottomContainerView.layer.borderWidth = 2
        BottomContainerView.layer.borderColor = Constants.normalWhiteBlack?.cgColor
        BottomContainerView.backgroundColor = UIColor(named: "bottomcardBackground")
        
        textTextView.backgroundColor = .clear
        textTextView.layer.borderWidth = 3
        textTextView.layer.borderColor = Constants.orangeFDB903?.cgColor
        textTextView.layer.cornerRadius = 15
        textTextView.font = UIFont(name: Constants.fontMedium, size: 20)
        textTextView.autocapitalizationType = .sentences
        textTextView.textColor = Constants.blackWhite
        
        TaskPickerView.delegate = self
        TaskPickerView.dataSource = self
        TaskPickerView.backgroundColor = .clear
        TaskPickerView.layer.cornerRadius = 20
        
        guard let str = delegate2?.numberOfExistingTasks(of: currentTasktype) else {return}
        currentTaskCountLabel.text = "\(str)/5"
        
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = UIFont(name: Constants.avenirBlackSuperBold, size: 19)
        
        textTextView.text = task.title
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
        
        let title = isEditingTask ? "Update Task" : "Save Task"
        saveButton.setTitle(title, for: .normal)
        
        eyesImageView.image = UIImage(named: apperance.eyes.randomElement() ?? "eyes2")
        eyesImageView.contentMode = .scaleAspectFit
    }
    
    private func setupGesture(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToDismissKeybord))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    private func observeKeyboard(){
        /// to observe when the keyboard is available and push the bottom card up or down
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //  MARK: - Combine
    private func observeForm() {
        let notificationName = UITextView.textDidChangeNotification
        NotificationCenter.default.publisher(for: notificationName).map { (notification) -> String? in
            return (notification.object as? UITextView)?.text
        }.sink {[unowned self] (text) in
            self.taskString = text
        }.store(in: &subscribers)
        
        /// change button enable status based on taskString status
        $taskString.sink {[weak self] (text) in
            guard let self = self else { return }
            self.saveButton.isEnabled =
                text?.isEmpty == false &&
                text?.meetsCharCount(of: Constants.textCharacterCount) == true &&
                text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }.store(in: &subscribers)
        
        /// monitor character count
        $taskString.sink {[weak self] (text) in
            guard let self = self else { return }
            guard let text = text else { return }
            self.descriptionCharCountLabel.alpha = self.updateAlphaPerCharCount(for: text)
            self.descriptionCharCountLabel.text = "- \(text.count - Constants.textCharacterCount)"
        }.store(in: &subscribers)
    }
    
    private func updateTask() {
        task.title = taskString
        task.taskType = currentTasktype
    }
    
    private func updateAlphaPerCharCount(for text: String) -> CGFloat{
        if text.count < Constants.textCharacterCount{
            return 0
        }
        return 1
    }
    
    private func enableButtonPerCharCount(for text: String) -> Bool {
        if text.count < Constants.textCharacterCount{
            return true
        }
        return false
    }
    
    @discardableResult private func isAble(toAdd task: Task) -> Bool {
        
        let errorText = taskManager.currentTasktypeMeetsRestriction(for: task)
        
        if errorText != nil {
            errorMsgLabel.text = errorText
            errorMsgLabel.textColor = .red
            
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {[weak self] in
                self?.errorMsgLabel.text = "Little things make big days."
                self?.errorMsgLabel.textColor = Constants.blackWhite
            }
            return false
            
        } else {
            errorMsgLabel.text = "Little things make big days."
            errorMsgLabel.textColor = Constants.orangeFDB903
        }
        
        return true
    }
}

//  MARK: - UIPickerViewDelegate
extension AddNewTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
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
        pickerLabel?.text = TaskType.allCases[row].debugDescription
        pickerLabel?.textColor = textColor
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            currentTasktype = .one
            guard let str = delegate2?.numberOfExistingTasks(of: currentTasktype) else {return}
            currentTaskCountLabel.text = "\(str)/1"
        case 1:
            currentTasktype = .three
            guard let str = delegate2?.numberOfExistingTasks(of: currentTasktype) else {return}
            currentTaskCountLabel.text = "\(str)/3"
        case 2:
            currentTasktype = .five
            guard let str = delegate2?.numberOfExistingTasks(of: currentTasktype) else {return}
            currentTaskCountLabel.text = "\(str)/5"
        
        default:
            break
        }
        
        updateTask()
        
    }
}

