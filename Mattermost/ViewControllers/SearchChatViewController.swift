//
//  SearchChatViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

struct SearchStage {
    static let SearchNotStarted: Int       = 0
    static let SearchRequstInProgress: Int = 1
    static let SearchResultsDisplay: Int   = 2
    static let SearchNoResults: Int        = 3
}

private protocol LifeCycle {
    func viewDidLoad()
    func didReceiveMemoryWarning()
}

private protocol Private {
    func configureForSearchStage(_ searchStage: Int)
}

private protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
    func setupSearchView()
}

private protocol Requests {
    
}

private protocol Action {
    func cancelBarButtonAction(_ sender: AnyObject)
}

private protocol Navigation {
    func returnToChat()
    func proceedToChatWithPost(post: Post)
}

class SearchChatViewController: UIViewController {
    
//MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var loadingEmozziView: UIView!
    
    fileprivate var searchingInProcessView: SearchingInProcessView?
    fileprivate lazy var builder: SearchCellBuilder = SearchCellBuilder(tableView: self.tableView)
    fileprivate var channel: Channel?
    
    fileprivate var posts: Array<Post>! = Array()
    fileprivate var dates: Array<NSDate>! = Array()
    
    
//MARK: Public
    
    func configureWithChannel(channel: Channel) {
        self.channel = channel
    }
}


//MARK: Life cycle

extension SearchChatViewController: LifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureForSearchStage(SearchStage.SearchNotStarted)
    }
}


//MARK: Setup

extension SearchChatViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
        setupSearchView()
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(FeedSearchTableViewCell.self, forCellReuseIdentifier: FeedSearchTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedSearchAttachmentTableViewCell.self, forCellReuseIdentifier: FeedSearchAttachmentTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    func setupSearchView() {
        self.searchingInProcessView = SearchingInProcessView.monkeyChatSearchView()
        self.searchingInProcessView?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.searchingInProcessView!)
        
        self.searchingInProcessView!.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.searchingInProcessView!.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
}


//MARK: Private

extension SearchChatViewController: Private {
    func configureForSearchStage(_ searchStage: Int) {
        self.infoView.isHidden = (searchStage != SearchStage.SearchNotStarted)
        self.loadingEmozziView.isHidden = (searchStage != SearchStage.SearchRequstInProgress)
        self.tableView.isHidden = (searchStage != SearchStage.SearchResultsDisplay)
        self.noResultView.isHidden = (searchStage != SearchStage.SearchNoResults)
        
        if (self.loadingEmozziView.isHidden) {
            self.searchingInProcessView?.hide()
        }
        else {
            self.searchingInProcessView?.show()
        }
    }
    
    func postsForDate(date: NSDate) -> [Post] {
        let predicate = NSPredicate(format: "day.date == %@", argumentArray: [date])
        let filteredPosts = self.posts.filter{ predicate.evaluate(with: $0) }
        
        return filteredPosts
    }
}


//MARK: Action

extension SearchChatViewController {
    @IBAction func cancelBarButtonAction(_ sender: AnyObject) {
        returnToChat()
    }
}


//MARK: Navigation

extension SearchChatViewController {
    func returnToChat() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromTop
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func proceedToChatWithPost(post: Post) {
        let viewControllers: Array = (self.navigationController?.viewControllers)!
        let chat: ChatViewController = viewControllers[viewControllers.count - 2] as! ChatViewController
        
        //post.computeMissingFields()
        RealmUtils.save(post)
        chat.configureWithPost(post: post)
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: FetchedResultsController

extension SearchChatViewController {
    func prepareSearchResults() {
        let terms = self.searchTextField.text!
        if ((terms as NSString).length > 0) {
            configureForSearchStage(SearchStage.SearchRequstInProgress)
            searchWithTerms(terms: terms)
        }
        else {
            configureForSearchStage(SearchStage.SearchNotStarted)
        }
    }
}


//MARK: Requests

extension SearchChatViewController: Requests {
    func searchWithTerms(terms: String) {
        PostUtils.sharedInstance.searchTerms(terms: terms, channel: self.channel!) { (posts, error) in
            if (error == nil) {
                self.posts = posts
                self.dates.removeAll()
                if (self.posts.count == 0) {
                    self.configureForSearchStage(SearchStage.SearchNoResults)
                }
                else {
                    for post in self.posts {
                        let day = post.day!
                        let index = (self.dates as NSArray).index(of: day.date!)
                        if (index == NSNotFound) {
                            self.dates.append(day.date! as NSDate)
                        }
                    }
                    
                    DispatchQueue.main.async{
                        self.configureForSearchStage(SearchStage.SearchResultsDisplay)
                        self.tableView.reloadData()
                    }
                    
                    //self.configureForSearchStage(SearchStage.SearchResultsDisplay)
                    //self.tableView.reloadData()
                }
            }
        }
    }
}


//MARK: UITableViewDataSource

extension SearchChatViewController: UITableViewDataSource {
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.dates.count != 0) ? self.dates.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section < self.dates.count) ? postsForDate(date: self.dates[section]).count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        let cell = self.builder.cellForPost(post: post, searchingText: self.searchTextField.text!)
        (cell as! FeedSearchTableViewCell).disclosureTapHandler = {
            self.proceedToChatWithPost(post: post)
        }
        
        return cell
    }
}


//MARK: UITableViewDelegate

extension SearchChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeedTableViewSectionHeader.reuseIdentifier()) as? FeedTableViewSectionHeader
        if view == nil {
            view = FeedTableViewSectionHeader(reuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
        }
        let titleString = (section < self.dates.count) ? (self.dates[section] as Date).feedSectionDateFormat() : ""
        view?.configureWithTitle(titleString)
        view?.transform = tableView.transform
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FeedTableViewSectionHeader.height()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        return self.builder.heightForPost(post: post)
    }
}


//MARK: UITextFieldDelegate

extension SearchChatViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString: NSString = textField.text! as NSString
        textField.text = newString.replacingCharacters(in: range, with: string)
        prepareSearchResults()
        
        return false
    }
}
