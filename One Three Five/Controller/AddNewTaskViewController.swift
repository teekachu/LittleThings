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
    
    //  MARK: Properties
    @Published private var taskString: String? ///Observe this variable because this is what will be updated as we type into the textfield
    private var currentTasktype: TaskType = .one
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    weak var delegate: TaskVCDelegate?
    
    //  MARK: IBProperties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var BottomContainerView: UIView!
    @IBOutlet weak var TaskTextfield: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var TaskPickerView: UIPickerView!
    @IBOutlet weak var deadlineTimeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let taskString = self.taskString else {return}
        let task = Task(title: taskString, taskType: currentTasktype)
        delegate?.didAddTask(for: task)
    }
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGesture()
        observeKeyboard()
        observeForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TaskTextfield.becomeFirstResponder()
    }
    
    //  MARK: Selectors
    @objc func tapToDismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut) {[weak self] in
            /// pushes the bottomVC up by keyboardHeight but down by 20, which is the space of bottom between stackview and container)
            self?.containerViewBottomConstraint.constant = keyboardHeight - 20
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
    }
    
    //  MARK: Privates
    private func configureUI(){
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        
        BottomContainerView.layer.cornerRadius = 25
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
        
        typeLabel.text = "Task \nType"
        typeLabel.textAlignment = .center
        //        typeLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        typeLabel.layer.cornerRadius = 30
        
        TaskPickerView.delegate = self
        TaskPickerView.dataSource = self
        
        saveButton.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1).withAlphaComponent(0.3)
//        saveButton.setWidth(width: 44)
        saveButton.tintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        saveButton.layer.cornerRadius = 15
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func observeKeyboard(){
        /// to observe when the keyboard is available and push the bottom card up or down
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //  MARK: Combine
    private func observeForm() {
        let notificationName = UITextField.textDidChangeNotification
        NotificationCenter.default.publisher(for: notificationName).map { (notification) -> String? in
            return (notification.object as? UITextField)?.text
        }.sink {[unowned self] (text) in
            self.taskString = text
        }.store(in: &subscribers)
        
        /// change button enable status based on taskString is empty or not
        $taskString.sink { (text) in
            self.saveButton.isEnabled = text?.isEmpty == false
        }.store(in: &subscribers)
    }
}

//  MARK: Extensions
extension AddNewTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource, Animatable{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TaskType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = TaskType.allCases[row].rawValue
        let textColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        let myTitle = NSAttributedString(
            string: titleData,
            /// TODO: WHY IS THE FONT NOT WORKING
            attributes: [NSAttributedString.Key.font: UIFont(name: Constants.textFontName, size: 12.0)!,
                         NSAttributedString.Key.foregroundColor: textColor])
        return myTitle
    }
    
    //    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    //
    //        let textColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    //        var pickerLabel: UILabel? = (view as? UILabel)
    //        if pickerLabel == nil {
    //            pickerLabel = UILabel()
    //            pickerLabel?.font = UIFont(name: Constants.textFontName, size: 12.0)
    //            pickerLabel?.textAlignment = .center
    //        }
    //        pickerLabel?.text = taskTypeDataSource[row]
    //        pickerLabel?.textColor = textColor
    //
    //        return pickerLabel!
    //    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            currentTasktype = .one
        //            printDebug(message: "Selected One large")
        case 1:
            currentTasktype = .three
        //            printDebug(message: "Selected Three mid")
        case 2:
            currentTasktype = .five
        //            printDebug(message: "Selected Five small")
        default:
            break
        }
    }
    
    
}
