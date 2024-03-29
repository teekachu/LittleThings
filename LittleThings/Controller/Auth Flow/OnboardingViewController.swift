//
//  OnboardingViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/9/20.
//

import UIKit
import paper_onboarding

/// 1) create a protocol that takes in an onboarding controller
protocol OnboardingControllerDelegate: class {
    func controllerWantsToDismiss(_ controller: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: OnboardingControllerDelegate?
    private var onboardingItems = [OnboardingItemInfo]()
    private var onboardingView = PaperOnboarding()
    private let getStartedButton: UIButton = {
        let butn = UIButton()
        butn.setTitle("I am ready to get started! ", for: .normal)
        butn.setTitleColor(Constants.whiteSmoke, for: .normal)
        butn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        butn.tintColor = Constants.whiteSmoke
        butn.semanticContentAttribute = .forceRightToLeft
        butn.alpha = 0
        butn.titleLabel?.font = UIFont(name: Constants.fontBold, size: 17)
        return butn
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureOnboardingDatasource()
    }
    
    //MARK: - Helpers
    private func animateGetStartedButton(_ shouldShow: Bool) {
        let alpha: CGFloat = shouldShow ? 1 : 0
        UIView.animate(withDuration: 0.5) {
            self.getStartedButton.alpha = alpha
        }
    }
    
    //MARK: - Selectors
    @objc func dismissOnboardingScreen(){
        delegate?.controllerWantsToDismiss(self)
    }
    
    @objc func learnMoreTapped(){
        let vc = AppInfoViewController()
        present(a: vc)
    }
    
    //MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        view.addSubview(onboardingView)
        onboardingView.fillSuperview()
        onboardingView.delegate = self
        
        view.addSubview(getStartedButton)
        getStartedButton.addTarget(self, action: #selector(dismissOnboardingScreen), for: .touchUpInside)
        getStartedButton.centerX(inView: view)
        getStartedButton.anchor(bottom: view.bottomAnchor, paddingBottom: 82, height: 44)
    }
    
    private func configureOnboardingDatasource(){
        /// set up onboarding items
        let itemOne = OnboardingItemInfo(
            informationImage: #imageLiteral(resourceName: "onboarding1")
                .withRenderingMode(.alwaysOriginal),
            title: "Hey there!",
            description: "Welcome to Little Things, your simple daily task manager",
            pageIcon: UIImage(),
            color: Constants.offBlack202020,
            titleColor: Constants.lightGrayCDCDCD,
            descriptionColor: Constants.innerYellowFCD12A,
            titleFont: UIFont(name: Constants.titleTextFont, size: 24)!,
            descriptionFont: UIFont(name: Constants.detailSubtitleTextFont, size: 19)!,
            descriptionLabelPadding: 0,
            titleLabelPadding: 0)
        
        let itemTwo = OnboardingItemInfo(
            informationImage: #imageLiteral(resourceName: "onboarding2")
                .withRenderingMode(.alwaysOriginal),
            title: "Let us help with your endless number of things to accomplish each day",
            description: "Keep your daily to-do items short and sweet",
            pageIcon: UIImage(),
            color: Constants.offBlack202020,
            titleColor: Constants.innerYellowFCD12A,
            descriptionColor: Constants.lightGrayCDCDCD,
            titleFont: UIFont(name: Constants.titleTextFont, size: 21)!,
            descriptionFont: UIFont(name: Constants.detailSubtitleTextFont, size: 18)!,
            descriptionLabelPadding: 0,
            titleLabelPadding: 20)
        
        let itemThree = OnboardingItemInfo(
            informationImage: #imageLiteral(resourceName: "time")
                .withRenderingMode(.alwaysOriginal),
            title: "Use the 1-3-5 rule to prioritize and tackle",
            description: "Organize your tasks by large, medium and small",
            pageIcon: UIImage(),
            color: Constants.offBlack202020,
            titleColor: Constants.lightGrayCDCDCD,
            descriptionColor: Constants.innerYellowFCD12A,
            titleFont: UIFont(name: Constants.titleTextFont, size: 21)!,
            descriptionFont: UIFont(name: Constants.detailSubtitleTextFont, size: 18)!,
            descriptionLabelPadding: 0,
            titleLabelPadding: 0)
        
        let itemFour = OnboardingItemInfo(
            informationImage: #imageLiteral(resourceName: "onboarding4")
                .withRenderingMode(.alwaysOriginal),
            title: "Focus your energy on the 9 things that matter",
            description: "And enjoy the rest of your day guilt free",
            pageIcon: UIImage(),
            color: Constants.offBlack202020,
            titleColor: Constants.lightGrayCDCDCD,
            descriptionColor: Constants.innerYellowFCD12A,
            titleFont: UIFont(name: Constants.titleTextFont, size: 21)!,
            descriptionFont: UIFont(name: Constants.detailSubtitleTextFont, size: 18)!,
            descriptionLabelPadding: 0,
            titleLabelPadding: 0)
        
        
        onboardingItems.append(itemOne)
        onboardingItems.append(itemTwo)
        onboardingItems.append(itemThree)
        onboardingItems.append(itemFour)
        
        onboardingView.dataSource = self
        onboardingView.reloadInputViews()
    }
}


//MARK: - PaperOnboardingDataSource
extension OnboardingViewController: PaperOnboardingDataSource{
    func onboardingItemsCount() -> Int {
        return onboardingItems.count
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return onboardingItems[index]
    }
}

//MARK: - PaperOnboardingDelegate
extension OnboardingViewController: PaperOnboardingDelegate{
    func onboardingWillTransitonToIndex(_ index: Int) {
        /// using viewmodels instead.
        let viewmodel = OnboardingViewModel(itemcount: onboardingItems.count)
        let shouldshow = viewmodel.shouldShowGetStartedButton(for: index)
        animateGetStartedButton(shouldshow)
    }
}


