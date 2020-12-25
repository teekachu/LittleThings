//
//  SideMenuTableViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/24/20.
//

import UIKit

protocol SideMenuDelegate: class {
    func sideMenu(didSelect option: MenuOption)
}

class SideMenuTableViewController: UIViewController {
    
    //  MARK: - Properties
    private let cellIdentifier = "SidemenuTableViewCell"
    private let delegate: SideMenuDelegate
    //var delegate: UINavigationControllerDelegate?
    
    //  MARK: - IB Properties
    private var tableview: UITableView!

    init(delegate: SideMenuDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        navigationController?.navigationBar.isHidden = true
        
    }
    
    //  MARK: - Selectors
    
    
    
    //  MARK: - Privates
    private func configureTableView(){
        tableview = UITableView()
        view.addSubview(tableview)
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(SidemenuTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableview.backgroundColor = Constants.offBlack202020
        tableview.separatorColor = .clear
        tableview.anchor(top: view.topAnchor,left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}


//  MARK: - UITableViewDataSource, UITableViewDelegate
extension SideMenuTableViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SidemenuTableViewCell
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.iconImageview.image = menuOption?.image
        cell.menuCellLabel.text = menuOption?.debugDescription
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Close menu and show the new VC
        tableView.deselectRow(at: indexPath, animated: true)
        guard let menuOption = MenuOption(rawValue: indexPath.row) else { return }

        dismiss(animated: true) { [weak self] in
            self?.delegate.sideMenu(didSelect: menuOption)
        }
//        delegate?.handleMenuToggle(for: menuOption)
        //        print("Selected \(indexPath.item)")
    }
}
