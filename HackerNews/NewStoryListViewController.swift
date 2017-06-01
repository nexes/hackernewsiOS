//
//  NewStoryListViewControllerTableViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/16/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit


class NewStoryListViewController: UITableViewController, HackerNewsStoriesDelegate {
    private var hackerNews: HackerNews?
    private var newStories = [HackerNewsStory]()
    private var storyDisplayCount = 30
    private var storiesAreLoading = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        hackerNews = HackerNews(withDelegate: self)
        hackerNews?.fetchNewStories(limitNumberOfStories: storyDisplayCount)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "New"
        navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 169/255, blue: 237/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Hacker News delegates
    
    func hackerNews(singleStoryCompleted story: HackerNewsStory) {
        newStories.append(story)
        tableView.insertRows(at: [IndexPath(row: newStories.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
        storiesAreLoading = false
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newStories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let storyCell = tableView.dequeueReusableCell(withIdentifier: "newStoryCell", for: indexPath) as? NewStoryViewCell {
            let story = newStories[indexPath.row]
            storyCell.hackerStory = story
            
            return storyCell
        }
        
        //shouldn't get here
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if storiesAreLoading == false && indexPath.row >= rowCount - 1 {
            storiesAreLoading = true
            hackerNews?.showAdditionalStories(count: storyDisplayCount)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabView = segue.destination as? UITabBarController
        
        if let storyView = tabView?.viewControllers?[0] as? StoryViewController {
            let story = newStories[(tableView.indexPathForSelectedRow?.row)!]
            storyView.hackerStory = story
        }
    }
}
