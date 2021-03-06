//
//  CreateChannelViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 09.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol CreateChannelViewControllerConfiguration: class {
    func configure(privateType: String)
}

class CreateChannelViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var headerPlaceholderLabel: UILabel!
    @IBOutlet weak var headerTextView: UITextView!
    @IBOutlet weak var purposePlaceholderLabel: UILabel!
    @IBOutlet weak var purposeTextView: UITextView!
    
    fileprivate var createButton: UIBarButtonItem!
    fileprivate var privateType: String! = ""
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
}


//MARK: Configuration
extension CreateChannelViewController: CreateChannelViewControllerConfiguration {
    func configure(privateType: String) {
        self.privateType = privateType
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
   // func setupNameTextField()
   // func setupHeaderTextField()
   // func setupPurposeTextField()
}

fileprivate protocol Action: class {
    func backAction()
    func createAction()
}

fileprivate protocol Navigation: class {
    func returnToChannel()
}

fileprivate protocol Request: class {

}


//MARK: Setup
extension CreateChannelViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupSwipeRight()
       // setupNameTextField()
       // setupHeaderTextField()
       // setupPurposeTextField()
    }
    
    func setupNavigationBar() {
        self.title = "New group"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.createButton = UIBarButtonItem.init(title: "Create", style: .done, target: self, action: #selector(createAction))
        self.createButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.createButton
    }
    
    func setupSwipeRight() {
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
 /*   func setupNameTextField() {
        self.nameTextField.lineHeight = 0
        self.nameTextField.selectedLineHeight = 0
        self.nameTextField.delegate = self
        self.nameTextField.tag = 0
    }
    
    func setupHeaderTextField() {
        self.headerTextField.lineHeight = 0
        self.headerTextField.selectedLineHeight = 0
        self.headerTextField.delegate = self
        self.headerTextField.tag = 1
    }
    
    func setupPurposeTextField() {
        self.purposeTextField.delegate = self
        self.purposeTextField.textColor = UIColor.clear
        self.purposeTextField.lineHeight = 0
        self.purposeTextField.selectedLineHeight = 0
        self.purposeTextField.tag = 2
    }*/
}


//MARK: Action
extension CreateChannelViewController: Action {
    func backAction() {
        returnToChannel()
    }
    
    func createAction() {
        createChannel()
    }
}


//MARK: Navigation
extension CreateChannelViewController: Navigation {
    func returnToChannel() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func returnToNew(channel: Channel) {
        (self.menuContainerViewController.leftMenuViewController as! LeftMenuViewController).updateSelectionFor(channel)
        ChannelObserver.sharedObserver.selectedChannel = channel
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension CreateChannelViewController: Request {
    func createChannel() {
        let name = self.nameTextField.text
        let header = self.headerTextView.text
        let purpose = self.purposeTextView.text
        self.createButton.isEnabled = false
        Api.sharedInstance.createChannel(self.privateType, name: name!, header: header!, purpose: purpose!) { (channel, error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                self.createButton.isEnabled = true
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
            AlertManager.sharedManager.showSuccesWithMessage(message: "Channel was successfully created")
            self.returnToNew(channel: channel!)
        }
    }
}


//MARK: Interface
extension CreateChannelViewController {
    func updateChannelLabel() {
        let name = self.nameTextField.text
        guard (name?.characters.count)! > 0 else { return }
        
        self.channelLabel.text = name?.capitalized[0]
    }
}


//MARK: UITextFieldsDelegate
extension CreateChannelViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString: NSString = textField.text! as NSString
        guard newString.length <= 30 else { return false }
        textField.text = newString.replacingCharacters(in: range, with: string)
        if textField == self.nameTextField {
            self.createButton.isEnabled = (newString.length > 0)
            updateChannelLabel()
        }
        
        return false
    }
}


//MARK: UITextViewDelegate
extension CreateChannelViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString: NSString = textView.text! as NSString
        textView.text = newString.replacingCharacters(in: range, with: text)
        if textView == self.headerTextView {
            self.headerPlaceholderLabel.isHidden = (textView.text.characters.count > 0)
        }
        else {
            self.purposePlaceholderLabel.isHidden = (textView.text.characters.count > 0)
        }
        
        return false
    }
}
