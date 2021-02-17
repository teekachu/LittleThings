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
        
        if taskCountSwitch.isOn {
            // set userDefault
            UserDefaults.standard.set(false, forKey: "CountSwitchIsOff")
            
            // change badge count
            guard let userID = authManager?.userID else {return}
            databaseManager?.getBadgeCount(for: userID) {[weak self] (count) in
                self?.notificationManager?.setBadge(to: count)
            }
            
        } else {
            UserDefaults.standard.set(true, forKey: "CountSwitchIsOff")
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        notificationManager?.register(UIApplication.shared)
    }
    
    
    @IBAction func purchaseOptionA(_ sender: Any) {
//        handleBaseTip()
        notificationManager?.setBadge(to: 5)
        print("Tapped")
    }
    @IBAction func purchaseOptionB(_ sender: Any) {
        handlePremiumTip()
    }
    @IBAction func restorePurchaseTapped(_ sender: Any) {
        handleRestorePurchase()
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
        configureCountSwitch()
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
        
        purchaseOptionA.layer.cornerRadius = 8
        fishSkeleton.layer.cornerRadius = 5
        
        fishboneStackview.layer.cornerRadius = 15
        fishboneStackview.layer.borderWidth = 2
        fishboneStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        
        purchaseOptionB.layer.cornerRadius = 8
        fishingImg.layer.cornerRadius = 5
        
        fishingStackview.layer.cornerRadius = 15
        fishingStackview.layer.borderWidth = 2
        fishingStackview.layer.borderColor = Constants.normalBlackWhite?.cgColor
        
        SKPaymentQueue.default().add(self)
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
        arr += [defaultIcon, rainbowIcon, blackCheckmarkIcon, CNYIcon, bwBallsIcon, rainbowHeart]
        for each in arr{
            each.layer.cornerRadius = 12
            each.imageView?.layer.cornerRadius = 12
            each.layer.borderWidth = 1.5
            each.layer.borderColor = Constants.normalBlackWhite?.cgColor
        }
    }
    
    private func configureCountSwitch(){
        taskCountSwitch.isOn = !UserDefaults.standard.bool(forKey: "CountSwitchIsOff")
//
//        if UserDefaults.exists(key: "CountSwitchIsOn") {
//            taskCountSwitch.isOn = UserDefaults.standard.bool(forKey: "CountSwitchIsOn")
//
//        } else {
//            // If doesn't exist, set it to true as default
//            UserDefaults.standard.setValue(true, forKey: "CountSwitchIsOn")
//            taskCountSwitch.isOn = UserDefaults.standard.bool(forKey: "CountSwitchIsOn")
//        }
    }
    
    //  MARK: - Payments
    func handleBaseTip() {
        
        showLottieAnimation(true)
        
        if SKPaymentQueue.canMakePayments() {
            showLottieAnimation(false)
            
            let transactionRequest = SKMutablePayment()
            transactionRequest.productIdentifier = basePurchaseID
            SKPaymentQueue.default().add(transactionRequest)
        } else {
            print("DEBUG: Unable to purchase base tip. ")
        }
    }
    
    func handlePremiumTip(){
        
        showLottieAnimation(true)
        
        if SKPaymentQueue.canMakePayments() {
            showLottieAnimation(false)
            
            let transactionRequest = SKMutablePayment()
            transactionRequest.productIdentifier = advancePurchaseID
            SKPaymentQueue.default().add(transactionRequest)
        } else {
            print("DEBUG: Unable to purchase advanced tip. ")
        }
    }
    
    func handleRestorePurchase(){
        
        showLottieAnimation(true)
        
        if SKPaymentQueue.canMakePayments() {
            showLottieAnimation(false)
            SKPaymentQueue.default().restoreCompletedTransactions()
            
        } else {
            print("Unable to restore purchase")
        }
    }
    
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


//  MARK: - Extensions
extension SettingsViewController: SKPaymentTransactionObserver, Animatable {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                
                fishQuoteLabel.text = "THANK YOU SO MUCH FOR YOUR SUPPORT!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {[weak self] in
                    
                    self?.fishQuoteLabel.text = "Give a Man a Fish, and You Feed Him for a Day. Teach a Man To Fish, and You Feed Him for a Lifetime”   -- Anne Ritchie, 1885"
                }
                break
                
            case .failed:
                showToast(state: .error, message: "UH OH, the transaction has failed.")
                break
                
            case .restored:
                print("restored successful...")
                
                fishQuoteLabel.text = "THANK YOU SO MUCH FOR YOUR PREVIOUS SUPPORT!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {[weak self] in
                    
                    self?.fishQuoteLabel.text = "Give a Man a Fish, and You Feed Him for a Day. Teach a Man To Fish, and You Feed Him for a Lifetime”   -- Anne Ritchie, 1885"
                }
                break
                
            default:
                print("default")
                break
            }
            
        }
    }
    
}
