//
//  NewTaskViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class NewTaskViewController: UIViewController {
    
    //  MARK: Properties
    /// Add the transparent affect
    private let backgroundView: UIView = {
        let v = UIView()
        v.frame = UIScreen.main.bounds
        v.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        return v
    }()
    
    private let bottomContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return v
    }()
    
    private let taskTextfield: UITextField = {
        let tf = UITextField()
        return tf
    }()
    
    private let placeholderDropdownMenu: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("PH for task type", for: .normal)
        btn.titleLabel?.font = UIFont(name: Constants.textFontName, size: 17)
        //        btn.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        return btn
    }()
    
    private let placeholderDeadlineTime: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("PH for deadline time picker", for: .normal)
        btn.titleLabel?.font = UIFont(name: Constants.textFontName, size: 17)
        //        btn.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        return btn
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save", for: .normal)
        btn.titleLabel?.font = UIFont(name: Constants.textFontName, size: 17)
        return btn
    }()
    
    private lazy var verticleMasterStackV: UIStackView = {
        let skv = UIStackView(arrangedSubviews: [
            taskTextfield,
            placeholderDropdownMenu,
            placeholderDeadlineTime,
            actionButton
        ])
        skv.axis = .vertical
        //        skv.backgroundColor = .lightGray
        skv.spacing = 10
        return skv
    }()
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextField()
        configureBottomView()
        configureStackview()
        setupGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        taskTextfield.becomeFirstResponder()
    }
    
    //  MARK: Selectors
    @objc func tapToDismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //  MARK: Privates
    private func configureUI(){
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        view.addSubview(backgroundView)
    }
    
    private func configureBottomView(){
        view.addSubview(bottomContainerView)
        bottomContainerView.layer.cornerRadius = 30
        bottomContainerView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
            ///  TODO: Update this
            //            ,height: 500
        )
    }
    
    private func configureTextField(){
        taskTextfield.placeholder = " Enter a new task"
        //        tf.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        taskTextfield.font = UIFont(name: Constants.textFontName, size: 16)
        taskTextfield.setHeight(height: 45)
        taskTextfield.borderStyle = .none
        taskTextfield.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func configureStackview(){
        view.addSubview(verticleMasterStackV)
        verticleMasterStackV.anchor(
            top: bottomContainerView.topAnchor,
            left: bottomContainerView.leftAnchor,
            bottom: bottomContainerView.bottomAnchor,
            right: bottomContainerView.rightAnchor,
            paddingTop: 20,
            paddingLeft: 16,
            paddingBottom: 30,
            paddingRight: 16)
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
}


//  MARK: Extensions
