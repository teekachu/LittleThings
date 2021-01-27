//
//  SettingsViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import UIKit

protocol SettingsMenuDelegate {
    func settingsMenu(didSelect option: SettingsOption)
}

protocol MotivationSwitchDelegate {
    func needMotivation(_ option: Bool)
}

class SettingsViewController: UIViewController {
    
    //  MARK: - Properties
    var delegate: SettingsMenuDelegate?
    var delegate2: MotivationSwitchDelegate?
    private let cellIdentifier = "settingsTableViewCell"
    let appIconManager = AppIconManager()
    var arr = [UIButton]()
    
    // MARK: - IB Property
    @IBOutlet weak var tableview: UITableView!
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var motivationSwitch: UISwitch!
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
    
    @IBAction func switchTapped(_ sender: Any) {
        if motivationSwitch.isOn {
            delegate2?.needMotivation(true)
        } else {
            delegate2?.needMotivation(false)
        }
    }
    
    @IBAction func purchaseOptionA(_ sender: Any) {
        print("Tapped support button of fish skeleton")
    }
    @IBAction func purchaseOptionB(_ sender: Any) {
        print("Tapped support button of fishing")
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
        configureUI()
        configureIconButtons()
        configureTableView()
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
