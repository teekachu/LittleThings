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
    var oldTask: Task?
    var newTaskString: String?
    weak var delegate: SwapTaskVCDelegate?
    
    //  MARK: - IB Properties
    
    @IBOutlet weak var currentTaskToFinishStackView: UIStackView!
    @IBOutlet weak var taskToFinishLabel: UILabel!
    @IBOutlet weak var oldTaskLabel: UILabel!
    @IBOutlet weak var taskToSwapWithLabel: UILabel!
    @IBOutlet weak var newTaskLabel: UILabel!
    @IBOutlet weak var swapButton: UIButton!
    @IBAction func tappedSwapActionButton(_ sender: Any) {
        guard let oldTask = oldTask else {return}
        guard let newString = newTaskString else {return}
        delegate?.didSwapTask(for: oldTask, with: newString)
    }
    
    //  MARK: - Lifecycle
    
    init(for task: Task, with newTask: String ) {
        self.oldTask = task
        self.newTaskString = newTask
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemChromeMaterial)
        navigationController?.navigationBar.isHidden = true
            
        taskToFinishLabel.textColor = Constants.swapModeText
        taskToSwapWithLabel.textColor = Constants.swapModeText
        
        currentTaskToFinishStackView.layer.borderWidth = 1
        currentTaskToFinishStackView.layer.cornerRadius = 22
        currentTaskToFinishStackView.layer.borderColor = Constants.mediumBlack3f3f3f.cgColor
        
        swapButton.layer.borderWidth = 1
        swapButton.layer.cornerRadius = 22
        swapButton.layer.borderColor = Constants.blackYellow?.cgColor
        
        oldTaskLabel.text = oldTask?.title
        newTaskLabel.text = newTaskString
        
    }
    
}

