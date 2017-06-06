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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyComments?.commentCount ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let commentCellView = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentViewCell else {
            return UITableViewCell()
        }
        
        let comment = (storyComments?[indexPath.row])!
        commentCellView.setupComment(withAuthor: comment.author, withText: comment.commentText, withDate: comment.time)
        
        return commentCellView
    }
}
