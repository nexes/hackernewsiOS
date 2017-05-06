//
//  HNListTableViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class HNListTableViewController: UITableViewController, HackerNewsStoriesDelegate {
  private var hackerNews: HackerNews!
  private var hackerNewsStories: [HackerNewsStory]?
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    hackerNews = HackerNews(withDelegate: self)
    hackerNews.fetchTopStories(limitNumberOfStories: 20)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableViewAutomaticDimension
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
    if let hackerNewsCell = tableView.dequeueReusableCell(withIdentifier: "HNcell", for: indexPath) as? HNListTableViewCell {
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
    if let storyView = segue.destination as? StoryViewController, segue.identifier == "storySegue" {
      if let index = tableView.indexPathForSelectedRow?.row, let story = hackerNewsStories?[index] {
        storyView.hackerStory = story
      }
    }
  }
}




