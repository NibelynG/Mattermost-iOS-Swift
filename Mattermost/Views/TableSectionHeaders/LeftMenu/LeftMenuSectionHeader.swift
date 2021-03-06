//
//  LeftMenuSectionHeader.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 11.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol LeftMenuSectionHeaderConfiguration {
    func configureWithChannelType(_ channelType: String!)
}

final class LeftMenuSectionHeader: UITableViewHeaderFooterView {
    
//MARK: Properties
    
    fileprivate let titleLabel: UILabel = UILabel()
    fileprivate let moreButton: UIButton = UIButton()
    static let reuseIdentifier = "LeftMenuSectionHeaderReuseIdentifier"
    var addTapHandler : (() -> Void)?
    
//MARK: Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: LeftMenuSectionHeaderConfiguration

extension LeftMenuSectionHeader: LeftMenuSectionHeaderConfiguration {
    func configureWithChannelType(_ channelType: String!) {
        self.titleLabel.text = channelType.uppercased()
        self.moreButton.isHidden = false
    }
    
    func hideMoreButton() {
        self.moreButton.isHidden = true
    }
}


private protocol LeftMenuSectionHeaderLifeCycle {
    func layoutSubviews()
}

private protocol LeftMenuSectionHeaderSetup {
    func initialSetup()
    func setupContentView()
    func setupTitleLabel()
    func setupMoreButton()
}

private protocol LeftMenuSectionHeaderAction {
    func moreAction()
}


//MARK: LeftMenuSectionHeaderLifeCycle

extension LeftMenuSectionHeader: LeftMenuSectionHeaderLifeCycle {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = CGRect(x: 15, y: 9, width: 150, height: 13)
        let xPos = self.bounds.maxX - 35
        self.moreButton.frame = CGRect(x: xPos, y: 7, width: 15, height: 15)
    }
}


//MARK: LeftMenuSectionHeaderSetup

extension LeftMenuSectionHeader: LeftMenuSectionHeaderSetup {
    func initialSetup() {
        setupContentView()
        setupTitleLabel()
        setupMoreButton()
    }
    
    func setupContentView() {
        self.contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.headerTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
        self.addSubview(self.titleLabel)
    }
    
    func setupMoreButton() {
        self.moreButton.setBackgroundImage(UIImage(named: "side_menu_more_icon"), for: UIControlState())
        self.moreButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        self.addSubview(self.moreButton)
    }
}


//MARK: LeftMenuSectionHeaderAction

extension LeftMenuSectionHeader : LeftMenuSectionHeaderAction {
    func moreAction() {
        if (self.addTapHandler != nil) {
            self.addTapHandler!()
        }
    }
}
