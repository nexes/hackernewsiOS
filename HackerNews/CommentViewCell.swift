//
//  CommentViewCell.swift
//  HackerNews
//
//  Created by Joe Berria on 5/9/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {
  @IBOutlet weak var commentTextLabel: UILabel!
  @IBOutlet weak var commentAuthorLabel: UILabel!
  @IBOutlet weak var commentDateLabel: UILabel!

  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func setupComment(withAuthor author: String, withText text: String, withDate date: String) {
    commentAuthorLabel.text = author
    commentTextLabel.text = text
    commentDateLabel.text = date
  }
}
