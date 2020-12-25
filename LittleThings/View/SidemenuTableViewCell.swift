//
//  SidemenuTableViewCell.swift
//  LittleThings
//
//  Created by Ting Becker on 12/24/20.
//

import UIKit

class SidemenuTableViewCell: UITableViewCell {

    //  MARK: - Properties
    let imageHeight:CGFloat = 25
    
    let iconImageview: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.backgroundColor = .clear
        img.tintColor = Constants.whiteSmoke
        return img
    }()
    
    let menuCellLabel: UILabel = {
       let lbl = UILabel()
        lbl.textColor = Constants.whiteSmoke
        lbl.font = UIFont(name: Constants.fontMedium, size: 16)
        lbl.text = "Sample Text"
        return lbl
    }()
    
    
    //  MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        configureIconImageView()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        backgroundColor = .clear
        textLabel?.textColor = Constants.whiteSmoke
        textLabel?.font = UIFont(name: Constants.fontMedium, size: 15)
    }

    private func configureIconImageView(){
        addSubview(iconImageview)
        iconImageview.centerY(inView: self)
        iconImageview.anchor(left: self.leftAnchor, paddingLeft: 10, width: imageHeight, height: imageHeight)
    }
    
    private func configureLabel(){
        addSubview(menuCellLabel)
        menuCellLabel.centerY(inView: self)
        menuCellLabel.anchor(left: iconImageview.rightAnchor, paddingLeft: 10)
    }
    
}

//  MARK: - Extensions
