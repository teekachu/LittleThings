//
//  DoneTableViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit

class DoneTableViewController: UIViewController {
    
    //  MARK: Properties
    let cellID = "doneCell"
    private var tableView: UITableView!
    
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //  MARK: Selectors
    
    
    //  MARK: Privates
    private func configureUI(){
        
        let tableView = UITableView()
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "DoneTaskTableViewCell", bundle: nil),
            forCellReuseIdentifier: cellID
        )
        
        tableView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        self.tableView = tableView
    }
    
}

//  MARK: Extensions
extension DoneTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? DoneTaskTableViewCell else {
            fatalError()
        }
        
      return cell
    }
    
}

