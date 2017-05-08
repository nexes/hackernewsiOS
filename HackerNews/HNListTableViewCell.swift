//
//  HNListTableViewCell.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class HNListTableViewCell: UITableViewCell {
  @IBOutlet weak var storyTitleLabel: UILabel!
  @IBOutlet weak var storyAuthorLabel: UILabel!
  @IBOutlet weak var storyDateLabel: UILabel!
  @IBOutlet weak var storyCountLabel: UILabel!
  @IBOutlet weak var storyCommentCountLabel: UILabel!
  
  
  var story: HackerNewsStory! {
    didSet{
      updateCellLabels()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  private func updateCellLabels() {
    storyTitleLabel.text = story.Title
    storyAuthorLabel.text = story.Author
    storyDateLabel.text = story.Time?.description
    storyCountLabel.text = "score \(story.Score)"
    storyCommentCountLabel.text = "\(story.CommentCount)" //umm
  }
}
