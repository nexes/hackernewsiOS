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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hackerNews = HackerNews(withDelegate: self)
    hackerNews?.fetchNewStories(limitNumberOfStories: 20)
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tabBarController?.title = "New"
    navigationController?.navigationBar.barTintColor = UIColor.green
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return newStories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let storyCell = tableView.dequeueReusableCell(withIdentifier: "newStoryCell", for: indexPath) as? NewStoryViewCell {
      let story = newStories[indexPath.row]
      storyCell.hackerStory = story
      
      return storyCell
    }
    
    return UITableViewCell() //shouldn't get here
  }
  
  
  // MARK: - Hacker News delegates
  func hackerNews(singleStoryCompleted story: HackerNewsStory) {
    newStories.append(story)
    tableView.insertRows(at: [IndexPath(row: newStories.count - 1, section: 0)], with: .right)
  }
  
  func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
    
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
