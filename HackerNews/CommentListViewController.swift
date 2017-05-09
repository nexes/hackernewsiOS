//
//  HNCommentViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/8/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class CommentListViewController: UITableViewController {
  public var storyComments: HackerStoryComments?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storyComments?.commentCount ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cellView = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentViewCell {
      if let comment = storyComments?[indexPath.row] {
        cellView.setupComment(withAuthor: comment.author, withText: comment.commentText, withDate: "some time")
        return cellView
      }
    }
    
    return UITableViewCell() // shouldn't get here
  }
}
