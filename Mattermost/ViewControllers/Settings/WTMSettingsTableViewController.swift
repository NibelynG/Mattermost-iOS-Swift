//
//  WTMSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class WTMSettingsTableViewController: UITableViewController {
 
//MARK: Properties
    fileprivate var saveButton: UIBarButtonItem!
    
    fileprivate lazy var builder: WTMSettingsCellBuilder = WTMSettingsCellBuilder(tableView: self.tableView)
    fileprivate var notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
    fileprivate let user = DataManager.sharedInstance.currentUser
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action {
    func backAction()
    func saveAction()
}

fileprivate protocol Navigation {
    func returtToNSettings()
}

fileprivate protocol Request {
    func updateSettings()
}


//MARK: Setup
extension WTMSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupSwipeRight()
    }
    
    func setupNavigationBar() {
        self.title = "Mobile push notifications"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupSwipeRight() {
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
}
    

//MARK: Action
extension WTMSettingsTableViewController: Action {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        updateSettings()
    }
}


//MARK: Navigation
extension WTMSettingsTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension WTMSettingsTableViewController: Request {
    func updateSettings() {
        let firstName = self.builder.firstNameState()
        let channel = self.builder.channelState()
        let mentionKeys = self.builder.mentionKeysState()
        
        try! RealmUtils.realmForCurrentThread().write {
            self.notifyProps?.firstName = firstName
            self.notifyProps?.channel = channel
            self.notifyProps?.mentionKeys = mentionKeys
        }
        
        Api.sharedInstance.updateNotifyProps(self.notifyProps!) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            self.saveButton.isEnabled = false
            let message = "User notification properties were successfully updated"
            AlertManager.sharedManager.showSuccesWithMessage(message: message)
        }
    }
}


//MARK: UITableViewDataSource
extension WTMSettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.builder.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.builder.numberOfRows(section: section)
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(notifyProps: self.notifyProps!, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension WTMSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        self.saveButton.isEnabled = true
        self.builder.switchCellState(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight(section: indexPath.section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.builder.headerTitle(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.builder.footerTitle(section: section)
    }
}


//MARK: UITextViewDelegate
extension WTMSettingsTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.saveButton.isEnabled = true
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TextSettingsTableViewCell
        
        cell.placeholderLabel?.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TextSettingsTableViewCell
        
        cell.placeholderLabel?.isHidden = (textView.text.characters.count == 0)
    }
}
