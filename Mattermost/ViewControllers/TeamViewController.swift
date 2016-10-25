//
//  TeamViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 02.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class TeamViewController: UIViewController {
    
//MARK: Properties
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var realm: Realm?
    fileprivate var results: Results<Team>! = nil
    fileprivate lazy var builder: TeamCellBuilder = TeamCellBuilder(tableView: self.tableView)
    
}


private protocol TeamViewControllerLifeCycle {
    func viewDidLoad()
}

private protocol TeamViewControllerSetup {
    func initialSetup()
    func setupTitleLabel()
    func setupTableView()
    func setupNavigationView()
}

private protocol TeamViewControllerAction {
    func backAction()
}

private protocol TeamViewControllerNavigation {
    func returnToChat()
}

private protocol TeamViewControllerConfiguration {
    func prepareResults()
}

private protocol TeamViewControllerRequest {
    func reloadChat()
}


//MARK: TeamViewControllerLifeCycle

extension TeamViewController: TeamViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        prepareResults()
    }
}


//MARK: TeamViewControllerSetup

extension TeamViewController: TeamViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupTitleLabel()
        setupTableView()
        setupNavigationView()
    }
    
    func setupNavigationBar() {
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon2"), style: .done, target: self, action: #selector(backAction))
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(TeamTableViewCell.classForCoder(), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleURLFont
        self.titleLabel.text = Preferences.sharedInstance.siteName
        self.titleLabel.textColor = ColorBucket.whiteColor
    }
    
    func setupNavigationView() {
        let bgLayer = CAGradientLayer.blueGradientForNavigationBar()
        bgLayer.frame = CGRect(x:0,y:0,width:self.navigationView.bounds.width,height: self.navigationView.bounds.height)
        bgLayer.animateLayerInfinitely(bgLayer)
        self.navigationView.layer.insertSublayer(bgLayer, at: 0)
        self.navigationView.bringSubview(toFront: self.titleLabel)
    }
}


//MARK: Action

extension TeamViewController: TeamViewControllerAction {
    func backAction() {
        returnToChat()
    }
}


//MARK: Navigation

extension TeamViewController: TeamViewControllerNavigation {
    func returnToChat() {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: Configuration

extension  TeamViewController: TeamViewControllerConfiguration  {
    func prepareResults() {
        let sortName = TeamAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Team.self).sorted(byProperty: sortName, ascending: true)
    }
}


//MARK: Request

extension TeamViewController: TeamViewControllerRequest {
    func reloadChat() {
        Api.sharedInstance.loadChannels(with: { (error) in
            Api.sharedInstance.loadCompleteUsersList({ (error) in
                RouterUtils.loadInitialScreen()
            })
        })
    }
}


//MARK: UITableViewDataSource

extension TeamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = self.results[indexPath.row]
        return self.builder.cellFor(team: team, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate

extension TeamViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = Team()
        if (Preferences.sharedInstance.currentTeamId != team.identifier) {
            Preferences.sharedInstance.currentTeamId = team.identifier
            self.reloadChat()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
