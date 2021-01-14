//
//  CustomTFViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/8/21.
//

import UIKit
import Combine

protocol CustomTextViewDelegate: class {
    func presentSwapVC(for oldTask: Task?, with newText: String?)
}

class CustomTVViewController: UIViewController {

    //  MARK: - Properties
    var taskToSwap: Task?
    @Published private var newTaskString : String?
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    private var viewmodel = SwapTaskViewModel()
    weak var delegate: CustomTextViewDelegate?
    
    //  MARK: - IB Properties
    @IBOutlet weak var alertContainerView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBAction func yesButtonTapped(_ sender: Any) {
        delegate?.presentSwapVC(for: taskToSwap, with: newTaskString)
    }
    @IBAction func noButtonTapped(_ sender: Any) {
        dismiss(animated: true)}
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        let msg = Constants.swapScreenExplaination
        let controller = CustomAlertViewController(alertMessage: msg)
        present(a: controller)
//        controller.modalPresentationStyle = .overCurrentContext
//        controller.modalTransitionStyle = .crossDissolve
//        present(controller, animated: true)
    }
    
    //  MARK: - Lifecycle
    init(for oldTask: Task) {
        self.taskToSwap = oldTask
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.view.frame.origin.y = -100
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0 }
    
    //  MARK: - Privates
    
    private func configureUI(){
        addBlurEffectToView(for: .systemThinMaterial)
        navigationController?.navigationBar.isHidden = true
        
        alertContainerView.backgroundColor = Constants.whiteOffblack
        alertContainerView.layer.cornerRadius = 25
        alertContainerView.layer.borderWidth = 1
        alertContainerView.layer.borderColor = Constants.bottomContainerBorder?.cgColor
        
        infoButton.layer.cornerRadius = 7
        textview.layer.borderWidth = 1
        textview.layer.borderColor = Constants.whiteOffblack?.cgColor
        textview.layer.cornerRadius = 15
        textview.becomeFirstResponder()
        textview.delegate = self
        
        yesButton.layer.borderWidth = 1
        yesButton.layer.cornerRadius = 15
        yesButton.layer.borderColor = Constants.whiteOffblack?.cgColor
        
        noButton.layer.borderWidth = 1
        noButton.layer.cornerRadius = 15
        noButton.layer.borderColor = Constants.swapCellBorder?.cgColor
    }
    
    private func addGestureToDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(CustomTVViewController.dismissKeyboard))
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
            self.yesButton.isEnabled =
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
extension CustomTVViewController: FormViewModel {
    func updateForm() {
        yesButton.isEnabled = viewmodel.shouldEnableButton
        yesButton.tintColor = viewmodel.buttonTitleColor
        yesButton.layer.borderColor = viewmodel.buttonLayerColor.cgColor
    }
}

extension CustomTVViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == textview {
            viewmodel.texts = textView.text
        }
        updateForm()
    }
}
