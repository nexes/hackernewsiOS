//
//  BestStoryViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/16/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit


class BestStoryViewController: UITableViewController, HackerNewsStoriesDelegate {
  private var bestStories = [HackerNewsStory]()
  private var hackerNews: HackerNews!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100

    hackerNews = HackerNews(withDelegate: self)
    hackerNews.fetchBestStories(limitNumberOfStories: 30)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tabBarController?.title = "Best"
    navigationController?.navigationBar.barTintColor = UIColor(red: 104/255, green: 216/255, blue: 141/255, alpha: 1)
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  // MARK: - Hacker News story delegates
  
  func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
    
  }
  
  func hackerNews(singleStoryCompleted story: HackerNewsStory) {
    bestStories.append(story)
    tableView.insertRows(at: [IndexPath(row: bestStories.count - 1, section: 0)], with: .right)
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return bestStories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let bestCell = tableView.dequeueReusableCell(withIdentifier: "bestStoryCell", for: indexPath) as? BestStoryViewCell {
      let story = bestStories[indexPath.row]
      bestCell.hackerStory = story
      
      return bestCell
    }
    
    return UITableViewCell() // shouldn't get here
  }
  
  // MARK: - Segue navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let tabView = segue.destination as? UITabBarController
    
    if let storyView = tabView?.viewControllers?[0] as? StoryViewController {
      let story = bestStories[(tableView.indexPathForSelectedRow?.row)!]
      storyView.hackerStory = story
    }
  }
}
