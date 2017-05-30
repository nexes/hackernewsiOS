//
//  StoryListViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class StoryListViewController: UITableViewController, HackerNewsStoriesDelegate {
    private var hackerNews: HackerNews!
    private var hackerNewsStories = [HackerNewsStory]()
    private var storyDisplayCount = 30
    private var storiesAreLoading = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hackerNews = HackerNews(withDelegate: self)
        hackerNews.fetchTopStories(limitNumberOfStories: storyDisplayCount)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Top"
        navigationController?.navigationBar.barTintColor = UIColor(red: 229/255, green: 165/255, blue: 36/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Hacker News delegate callbacks
    
    func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
        storiesAreLoading = false
    }
    
    func hackerNews(singleStoryCompleted story: HackerNewsStory) {
        hackerNewsStories.append(story)
        tableView.insertRows(at: [IndexPath(row: hackerNewsStories.count - 1, section: 0)], with: UITableViewRowAnimation.top)
    }
    
    
    // MARK: - TableView list refresh
    
    @IBAction func refreshStoryList(_ sender: UIRefreshControl) {
//        refreshControl?.beginRefreshing()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hackerNewsStories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let hackerNewsCell = tableView.dequeueReusableCell(withIdentifier: "HNcell", for: indexPath) as? StoryListViewCell {
            let story = hackerNewsStories[indexPath.row]
            hackerNewsCell.story = story
            
            return hackerNewsCell
        }
        
        //shouldn't get here
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if storiesAreLoading == false && indexPath.row >= rowCount - 1 {
            storiesAreLoading = true
            hackerNews.showAdditionalStories(count: storyDisplayCount)
        }
    }
    
    // MARK: - Segue preperation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarView = segue.destination as? UITabBarController {
            if let storyView = tabBarView.viewControllers?[0] as? StoryViewController { //need a better way to reference the view
                let hackerStory = hackerNewsStories[(tableView.indexPathForSelectedRow?.row)!]
                
                storyView.hackerStory = hackerStory
            }
        }
    }
}




