//
//  SwapTaskViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/31/20.
//

import UIKit
import Combine

protocol SwapTaskVCDelegate: class {
    func didSwapTask(for task: Task, with newTitle: String)
}

class SwapTaskViewController: UIViewController {
    
    //  MARK: - Properties
    var taskToSwap: Task?
    @Published private var newTaskString : String?
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    private var viewmodel = SwapTaskViewModel()
    weak var delegate: SwapTaskVCDelegate?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var questionMarkButton: UIButton!
    @IBOutlet weak var currentPriorityLabel: UILabel!
    @IBOutlet weak var currentTaskToFinishStackView: UIStackView!
    @IBOutlet weak var taskToFinishLabel: UILabel!
    @IBOutlet weak var taskTitleToFinishLabel: UILabel!
    @IBOutlet weak var taskToSwapWithStackView: UIStackView!
    @IBOutlet weak var taskToSwapWithLabel: UILabel!
    @IBOutlet weak var newTaskTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func questionButtonTapped(_ sender: Any) {
        let msg = """
        Welcome to Swap Mode:

        If you already have 9 tasks but need to add 1 more, you may use this screen to swap out the old task simply by accomplishing it. Yup, thats right. Let's get it done! When you are ready to swap, enter the new task in the bottom bubble and tap "SWAP IT", the old task will be moved to done, replaced by the new.
        """
        let controller = CustomAlertViewController(alertMessage: msg)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }
    
    @IBAction func tappedSwapActionButton(_ sender: Any) {
        handleSwapAction()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "savedTaskID")
        dismiss(animated: true)
    }
    
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addGestureToDismiss()
        observeKeyboard()
        observeForm()
    }
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true) }
    
    @objc func keyboardWillShow(_ notification: Notification){
        
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemChromeMaterial)
        navigationController?.navigationBar.isHidden = true
        questionMarkButton.layer.cornerRadius = 7
        
        newTaskTextView.delegate = self
        
        currentPriorityLabel.textColor = Constants.swapModeText
        taskToFinishLabel.textColor = Constants.swapModeText
        taskToSwapWithLabel.textColor = Constants.swapModeText
        
        currentTaskToFinishStackView.layer.borderWidth = 1
        currentTaskToFinishStackView.layer.cornerRadius = 22
        currentTaskToFinishStackView.layer.borderColor = Constants.swapCellBorder?.cgColor
        
        taskToSwapWithStackView.layer.borderWidth = 1
        taskToSwapWithStackView.layer.cornerRadius = 22
        taskToSwapWithStackView.layer.borderColor = Constants.swapCellBorder?.cgColor
        
        swapButton.layer.borderWidth = 1
        swapButton.layer.cornerRadius = 22
        swapButton.layer.borderColor = Constants.whiteOffblack?.cgColor
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 22
        cancelButton.layer.borderColor = Constants.swapCellBorder?.cgColor
        
        guard let tasktoswap = taskToSwap else {return}
        let taskStringToFinish = tasktoswap.title
        taskTitleToFinishLabel.text = taskStringToFinish
        /// This screen needs to be on top of everything else, and should not dismiss even if app was force closed .
    }
    
    private func handleSwapAction(){
        guard let taskToSwap = taskToSwap else {return}
        guard let newtaskstring = newTaskString else {return}
        delegate?.didSwapTask(for: taskToSwap, with: newtaskstring)
        dismiss(animated: true)
    }
    
    private func addGestureToDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(SwapTaskViewController.dismissKeyboard))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    private func observeKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func observeForm() {
        let notificationName = UITextView.textDidChangeNotification
        NotificationCenter.default.publisher(for: notificationName).map { (notification) -> String? in
            return (notification.object as? UITextView)?.text
        }.sink {[unowned self] (text) in
            self.newTaskString = text
        }.store(in: &subscribers)
        
        $newTaskString.sink {[weak self] (text) in
            guard let self = self else { return }
            self.swapButton.isEnabled =
                text?.isEmpty == false &&
                text?.meetsCharCount(of: Constants.textCharacterCount) == true &&
                text?.trimmingCharacters(in: .whitespaces) != ""
        }.store(in: &subscribers)
        
        $newTaskString.sink {[weak self] (text) in
            guard let self = self else { return }
            guard let text = text else { return }
            self.errorLabel.alpha = self.updateAlphaPerCharCount(for: text)
            self.errorLabel.text = " - \(text.count - Constants.textCharacterCount)"
        }.store(in: &subscribers)
    }
    
    private func updateAlphaPerCharCount(for text: String) -> CGFloat{
        if text.count < Constants.textCharacterCount{
            return 0
        }
        return 1
    }
}

//  MARK: - Extensions
extension SwapTaskViewController: FormViewModel {
    func updateForm() {
        swapButton.isEnabled = viewmodel.shouldEnableButton
        swapButton.tintColor = viewmodel.buttonTitleColor
        swapButton.layer.borderColor = viewmodel.buttonLayerColor.cgColor
    }
}

extension SwapTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == newTaskTextView {
            viewmodel.texts = textView.text
        }
        
        updateForm()
    }
}
