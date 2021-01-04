//
//  SwapTaskViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/31/20.
//

import UIKit

class SwapTaskViewController: UIViewController {
    
    //  MARK: - Properties
    var taskToFinish: String?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var questionMarkButton: UIButton!
    @IBOutlet weak var currentTaskToFinishStackView: UIStackView!
    @IBOutlet weak var currentPriorityLabel: UILabel!
    @IBOutlet weak var taskToFinishLabel: UILabel!
    @IBOutlet weak var taskToSwapWithLabel: UILabel!
    @IBOutlet weak var taskToSwapWithStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var swapButton: UIButton!
    @IBAction func questionButtonTapped(_ sender: Any) {
        let msg = "Welcome to Swap Mode:   If you already have 9 tasks but need to add 1 more, you may use this screen to swap out the old task simply by accomplishing it. Yup, thats right. Let's get it done! Enter the new task in the bottom bubble. When you are ready to swap, the old task will be moved to done, replaced by the new. "
        let controller = CustomAlertViewController(alertMessage: msg)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }

    @IBAction func tappedSwapActionButton(_ sender: Any) {
        handleSwapAction()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addGestureToDismiss()
        observeKeyboard()
    }
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true) }
    
    @objc func keyboardWillShow(_ notification: Notification){

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.view.frame.origin.y = -100
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
        swapButton.layer.borderColor = Constants.swapCellBorder?.cgColor
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 22
        cancelButton.layer.borderColor = Constants.swapCellBorder?.cgColor
        
        /// This screen needs to be on top of everything else, and should not dismiss even if app was force closed .
    }
    
    private func handleSwapAction(){
        print("Swap it")
        // check if task is less than 100 words
        // check if valid entry, same as in addTaskVC
        // when swap it is tapped, need to
        // 1. move the task in tapped cell to done,
        // 2. add new task
        
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
    
    
}

//  MARK: - Extensions
