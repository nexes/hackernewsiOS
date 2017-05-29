//
//  NewStoryViewCell.swift
//  HackerNews
//
//  Created by Joe Berria on 5/16/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class NewStoryViewCell: UITableViewCell {
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyAuthorLabel: UILabel!
    @IBOutlet weak var storyDateLabel: UILabel!
    @IBOutlet weak var storyScoreLabel: UILabel!
    @IBOutlet weak var storyCommentLabel: UILabel!
    
    var hackerStory: HackerNewsStory! {
        didSet{
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateUI() {
        storyTitleLabel.text = hackerStory.Title
        storyAuthorLabel.text = hackerStory.Author
        storyDateLabel.text = hackerStory.formatedStoryDate()
        storyCommentLabel.text = "\(hackerStory.CommentCount)"
        storyScoreLabel.text = "score: \(hackerStory.Score)"
    }
}
