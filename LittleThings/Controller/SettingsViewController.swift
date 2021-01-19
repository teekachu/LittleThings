//
//  SettingsViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import UIKit
import UserNotifications

protocol SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption)
}

class SettingsViewController: UIViewController {
    
    //  MARK: - Properties
    var delegate: SettingsMenuDelegate?
    private let cellIdentifier = "settingsTableViewCell"
    
    
    // MARK: - IB Property
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var toggleButton: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        sender.isOn ? registerLocal() : setLabelToEmpty()
    }
    
    @IBAction func reminderTimeChanged(_ sender: Any) {
        
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
    }
    
    
    //  MARK: - Privates
    private func setLabelToEmpty(){
        errorLabel.text = " "
    }
    
    private func configureTableView(){
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableview.backgroundColor = .clear
        tableview.separatorColor = Constants.cellBorderColor //292a27
    }
    
    private func registerLocal(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {[weak self] (granted, error) in
            if granted{
                print("Permission granted")
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
    
    private func createAlert(){
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
    }
    
    
}


//  MARK: - Extensions
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
