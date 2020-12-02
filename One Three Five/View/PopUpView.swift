//
//  PopUpView.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class PopUpView: UIView {
    
    //  MARK: Properties
    /// delete
    fileprivate let TaskTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Placeholder"
        return textfield
    }()
    /// delete
    fileprivate let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Pop up title"
        return label
    }()
    /// update
    fileprivate lazy var stackView: UIStackView = {
        let stkview = UIStackView()
        return stkview
    }()
    
    fileprivate let container: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.layer.cornerRadius = 25
        return view
    }()
    
    
    //  MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureContainerView()
        configureStackview()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: Selectors
    @objc func animateOut(){
        UIView.animate(withDuration: 0.3) {
            self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
            
        }
    }
    
    
    
    //  MARK: Privates
    private func configureUI(){
        /// this is the whole screen's background, underneath the pop up
        /// see through gray background
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        self.frame = UIScreen.main.bounds
        /// This has to be in configureUI, else code will crash
        self.addSubview(container)
        self.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(animateOut)))
    }
    
    private func configureContainerView(){
        container.centerX(inView: self)
        container.centerY(inView: self)
        container.anchor(
            width: UIScreen.main.bounds.width * 0.7,
            height: UIScreen.main.bounds.height * 0.45)
        container.addSubview(stackView)
    }
    
    /// update
    private func configureStackview(){
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(TaskTextfield)
        stackView.addArrangedSubview(label)
        
        stackView.anchor(
            top: container.topAnchor,
            left: container.leftAnchor,
            bottom: container.bottomAnchor,
            right: container.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20)
    }
    
}
