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
  private var hackerNewsStories: [HackerNewsStory]?
  
  
  override func awakeFromNib() {
    super.awakeFromNib()

    hackerNews = HackerNews(withDelegate: self)
    hackerNews.fetchTopStories(limitNumberOfStories: 30)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Top Stories"
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
    //        self.tableView.reloadData()
  }
  
  func hackerNews(singleStoryCompleted story: HackerNewsStory) {
    if hackerNewsStories == nil {
      hackerNewsStories = [HackerNewsStory]()
    }
    hackerNewsStories?.append(story)
    tableView.insertRows(at: [IndexPath(row: hackerNewsStories!.count - 1, section: 0)], with: UITableViewRowAnimation.right)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let hackerNewsCell = tableView.dequeueReusableCell(withIdentifier: "HNcell", for: indexPath) as? StoryListViewCell {
      if let story = hackerNewsStories?[indexPath.row] {
        hackerNewsCell.story = story
        
        return hackerNewsCell
      }
    }
    
    return UITableViewCell() //shouldn't get here
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hackerNewsStories?.count ?? 0
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let tabBarView = segue.destination as? UITabBarController {
      if let storyView = tabBarView.viewControllers?[0] as? StoryViewController { //need a better way to reference the view
        let hackerStory = hackerNewsStories?[(tableView.indexPathForSelectedRow?.row)!]
        storyView.hackerStory = hackerStory
      }
    }
  }
}




