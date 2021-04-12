//
//  SettingsViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import UIKit
import StoreKit


protocol SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption)
}

protocol MotivationSwitchDelegate {
    func needMotivation(_ option: Bool)
}

class SettingsViewController: UIViewController {
    
    //  MARK: - Properties
    let appIconManager = AppIconManager()
    let databaseManager: DatabaseManager?
    let authManager: AuthManager?
    let notificationManager: NotificationsManager?
    
    var delegate: SettingsMenuDelegate?
    var delegate2: MotivationSwitchDelegate?
    
    private let cellIdentifier = "settingsTableViewCell"
    
    var arr = [UIButton]()
    var IAPproducts = [SKProduct]()
    
    var basePurchaseID = "base_tip"
    var advancePurchaseID = "tip_advanced"
    
    // MARK: - IB Property
    @IBOutlet weak var tableview: UITableView!
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var motivationSwitch: UISwitch!
    @IBOutlet weak var taskCountSwitch: UISwitch!
    @IBOutlet weak var defaultIcon: UIButton!
    @IBOutlet weak var rainbowIcon: UIButton!
    @IBOutlet weak var blackCheckmarkIcon: UIButton!
    @IBOutlet weak var CNYIcon: UIButton!
    @IBOutlet weak var bwBallsIcon: UIButton!
    @IBOutlet weak var rainbowHeart: UIButton!
    @IBOutlet weak var littleThingIcon: UIButton!
    @IBOutlet weak var fishSkeleton: UIImageView!
    @IBOutlet weak var fishingImg: UIImageView!
    @IBOutlet weak var fishboneStackview: UIStackView!
    @IBOutlet weak var fishingStackview: UIStackView!
    @IBOutlet weak var purchaseOptionA: UIButton!
    @IBOutlet weak var purchaseOptionB: UIButton!
    @IBOutlet weak var fishQuoteLabel: UILabel!
    @IBAction func switchTapped(_ sender: Any) {
        if motivationSwitch.isOn {
            delegate2?.needMotivation(true)
        } else {
            delegate2?.needMotivation(false)
        }
    }
    @IBAction func taskCountSwitchTapped(_ sender: Any) {
        print("I tapped the task count switch to \(taskCountSwitch.state)")
        
//        if taskCountSwitch.isOn {
//            // set userDefault
//            UserDefaults.standard.set(false, forKey: "CountSwitchIsOff")
//
//            // change badge count
//            guard let userID = authManager?.userID else {return}
//            databaseManager?.getBadgeCount(for: userID) {[weak self] (count) in
//                self?.notificationManager?.setBadge(to: count)
//            }
//
//        } else {
//            UserDefaults.standard.set(true, forKey: "CountSwitchIsOff")
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
//
//        notificationManager?.register(UIApplication.shared)
    }
    @IBAction func purchaseOptionA(_ sender: Any) {
        PurchaseManager.shared.makePurchase(productID: .baseID)
    }
    @IBAction func purchaseOptionB(_ sender: Any) {
        PurchaseManager.shared.makePurchase(productID: .advanceID)
    }
    @IBAction func restorePurchaseTapped(_ sender: Any) {
        PurchaseManager.shared.restorePurchase()
    }
    
    
    //  MARK: - ICONS
    @IBAction func defaultIconTapped(_ sender: Any) {
        UIApplication.shared.setAlternateIconName(nil)
    }
    @IBAction func rainbowIconTaped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .rainbowAppIcon)
    }
    @IBAction func blackCheckmarkTapped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .blackCheckmarkAppIcon)
    }
    @IBAction func CNYIconTapped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .CNYAppIcon)
    }
    @IBAction func bwBallsIconTapped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .bwAppIcon)
    }
    @IBAction func rainbowHeartIconTapped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .rainbowHeartAppIcon)
    }
    @IBAction func littleThingIconTapped(_ sender: Any) {
        appIconManager.changeAppIcon(to: .yellowLTIcon)
    }
    
    
    
    //  MARK: - Lifecycle
    init(delegate: SettingsMenuDelegate,
         databaseManager: DatabaseManager,
         authManager: AuthManager,
         notificationManager: NotificationsManager ) {
        
        self.delegate = delegate
        self.databaseManager = databaseManager
        self.authManager = authManager
        self.notificationManager = notificationManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurEffectToView(for: .systemThickMaterial)
        configureUI()
        configureIconButtons()
        configureTableView()
//        configureCountSwitch()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        fishboneStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        fishingStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        
        for each in arr{
            each.layer.borderColor = Constants.normalBlackWhite?.cgColor
        }
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        
        if UserDefaults.exists(key: "IAPoptionAisEnabled"){
            purchaseOptionA.isEnabled = UserDefaults.standard.bool(forKey: "IAPoptionAisEnabled")
            purchaseOptionA.backgroundColor = .clear
            purchaseOptionA.setTitle("Thank You", for: .normal)
        }
        purchaseOptionA.layer.cornerRadius = 8
        fishSkeleton.layer.cornerRadius = 5
        
        fishboneStackview.layer.cornerRadius = 15
        fishboneStackview.layer.borderWidth = 2
        fishboneStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        
        if UserDefaults.exists(key: "IAPoptionBisEnabled"){
            purchaseOptionB.isEnabled = UserDefaults.standard.bool(forKey: "IAPoptionBisEnabled")
            purchaseOptionB.backgroundColor = .clear
            purchaseOptionB.setTitle("Thank You", for: .normal)
        }
        purchaseOptionB.layer.cornerRadius = 8
        fishingImg.layer.cornerRadius = 5
        
        fishingStackview.layer.cornerRadius = 15
        fishingStackview.layer.borderWidth = 2
        fishingStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        
        /// Fetch product info when settings menu is active
        PurchaseManager.shared.fetchAvailableProducts()
        PurchaseManager.shared.delegate = self
    }
    
    private func configureTableView(){
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableview.backgroundColor = .clear
        tableview.separatorColor = Constants.cellBorderColor //292a27
        tableview.layer.cornerRadius = 15
    }
    
    private func configureIconButtons(){
        arr += [defaultIcon, rainbowIcon, blackCheckmarkIcon, CNYIcon, bwBallsIcon, rainbowHeart, littleThingIcon]
        for each in arr{
            each.layer.cornerRadius = 12
            each.imageView?.layer.cornerRadius = 12
            each.layer.borderWidth = 1.5
            each.layer.borderColor = Constants.normalBlackWhite?.cgColor
        }
    }
    
//    private func configureCountSwitch(){
//        taskCountSwitch.isOn = !UserDefaults.standard.bool(forKey: "CountSwitchIsOff")
//    }
    
}


//  MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let settingsOption = SettingsOption(rawValue: indexPath.row)
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = settingsOption?.debugDescription
        cell.imageView?.image = settingsOption?.image
        cell.textLabel?.font = UIFont(name: Constants.menuFont, size: 17)
        cell.backgroundColor = Constants.whiteOffblack?.withAlphaComponent(0.75)
        
        cell.imageView?.tintColor = Constants.normalBlackWhite
        cell.textLabel?.textColor = Constants.normalBlackWhite
        
        let colorview = UIView()
        colorview.backgroundColor = Constants.settingsCellSelected
        cell.selectedBackgroundView = colorview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let settings = SettingsOption(rawValue: indexPath.row) else {return}
        dismiss(animated: true) { [weak self] in
            self?.delegate?.settingsMenu(didSelect: settings)
        }
    }
}


extension SettingsViewController: PurchaseManagerDelegate {
    func didPurchaseBaseProduct() {
        /// Show an alert as appreciation
        let alert = CustomAlertViewController(alertTitle: "THANK YOU", alertMessage: Constants.thankYouForYourPurchaseBase)
        alert.modalPresentationStyle = .fullScreen
        present(alert, animated: true)
        
        /// Hide the base product purchase button
        
        purchaseOptionA.isEnabled = false
        UserDefaults.standard.set(false, forKey: "IAPoptionAisEnabled")
        
        purchaseOptionA.setTitle("Thank You", for: .normal)
        purchaseOptionA.backgroundColor = .clear
        print("You bought the base product")
    
    }
    
    func didPurchaseAdvanceProduct() {
        /// Show an alert as appreciation
        let alert = CustomAlertViewController(alertTitle: "THANK YOU", alertMessage: Constants.thankYouForYourPurchaseAdv)
        alert.modalPresentationStyle = .fullScreen
        present(alert, animated: true)
        
        /// Hide the base product purchase button
        purchaseOptionB.isEnabled = false
        UserDefaults.standard.set(false, forKey: "IAPoptionBisEnabled")
        
        purchaseOptionB.setTitle("Thank You", for: .normal)
        purchaseOptionB.backgroundColor = .clear
        
        print("you bought the advanced product")
    }
    
}

