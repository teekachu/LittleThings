//
//  SettingsViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import UIKit
import UserNotifications
import Loaf

protocol SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption)
}

class SettingsViewController: UIViewController {
    
    //  MARK: - Properties
    var delegate: SettingsMenuDelegate?
    private let cellIdentifier = "settingsTableViewCell"
    let center = UNUserNotificationCenter.current()
    let defaults = UserDefaults.standard
    let keyToEnableNotification = "notifcation"

    
    
    // MARK: - IB Property
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var toggleButton: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            defaults.set(true, forKey: keyToEnableNotification)
            registerLocal()
        } else {
            turnOffAnyNotifications()
        }
    }
    
    @IBAction func reminderTimeChanged(_ sender: Any) {
        if toggleButton.isOn {
            showToast(state: .success, message: "Daily reminder scheduled.")
            scheduleLocal()
        } else {
            errorLabel.text = "Please toggle the switch to enable notifications first."
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
                self?.errorLabel.text = ""
            }
        }
    }
    
    
    //  MARK: - Lifecycle
    init(delegate: SettingsMenuDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurEffectToView(for: .systemThickMaterial)
        configureTableView()
        configureToggleStateBasedOnSettings()
    }
    
    
    //  MARK: - Privates
    private func configureTableView(){
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableview.backgroundColor = .clear
        tableview.separatorColor = Constants.cellBorderColor //292a27
    }
    
    private func configureToggleStateBasedOnSettings(){
        center.getNotificationSettings {[weak self] (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case.authorized:
                    guard let key = self?.keyToEnableNotification else {return}
                    let toggleState = self?.defaults.object(forKey: key) as? Bool ?? false
                    self?.toggleButton.isOn = toggleState
                    
                case.denied,.ephemeral, .notDetermined, .provisional:
                    self?.toggleButton.isOn = false
                    
                @unknown default:
                    self?.toggleButton.isOn = false
                }
            }
        }
    }
    
    //  MARK: - Notification
    private func registerLocal(){
        center.requestAuthorization(options: [.alert, .badge, .sound]) {[weak self] (granted, error) in
            if granted{
                //                print("Permission granted")
                DispatchQueue.main.async { [weak self] in
                    self?.errorLabel.text = " "
                    self?.toggleButton.isOn = true
                }
            } else {
                let errormsg = "Please go to your phone settings and grant permission to receive notifications"
                DispatchQueue.main.async {[weak self] in
                    self?.errorLabel.text = errormsg
                    self?.toggleButton.isOn = false
                }
            }
        }
    }
    
    private func scheduleLocal(){
        registerActions()
        
        let content = UNMutableNotificationContent()
        content.title = "Good morning!"
        content.body = "Your tasks miss you. It's a beautiful new day, don't forget to give them some love."
        content.categoryIdentifier = "reminderAlert"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 30
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true) // Test, every minute
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        center.add(request)
    }
    
    private func turnOffAnyNotifications(){
        defaults.removeObject(forKey: keyToEnableNotification)
        errorLabel.text = " "
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    private func registerActions(){
        center.delegate = self
        let showMore = UNNotificationAction(identifier: "view", title: "View", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [showMore], intentIdentifiers: [] )
        
        center.setNotificationCategories([category])
    }
}


//  MARK: - UNUserNotificationCenterDelegate
extension SettingsViewController: UNUserNotificationCenterDelegate, Animatable {
    // if app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // if app isnt running
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String{
            print("custom data received for : \(customData)")
            
            switch response.actionIdentifier{
            
            case UNNotificationDefaultActionIdentifier:
                print("the user swiped to unlock")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true)
                }
                
            case "view":
                dismiss(animated: true) {
                    print("User tapped view button")
                }
                
            default:
                break
            }
            
        }
        
        completionHandler()
    }
    
}


//  MARK: - UITableViewDataSource, UITableViewDelegate
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
        
        cell.imageView?.tintColor = Constants.blackWhite?.withAlphaComponent(0.75)
        cell.textLabel?.textColor = Constants.blackWhite?.withAlphaComponent(0.75)
        cell.layer.cornerRadius = 12
        
        let colorview = UIView()
        colorview.backgroundColor = Constants.settingsCellSelected
        cell.selectedBackgroundView = colorview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let settings = SettingsOption(rawValue: indexPath.row) else {return}
        dismiss(animated: true) { [weak self] in
            self?.delegate?.settingsMenu(didSelect: settings)
        }
    }
    
    
}
