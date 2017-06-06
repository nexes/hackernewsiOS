//
//  FavoriteStoryViewCell.swift
//  HackerNews
//
//  Created by Joe Berria on 6/4/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class FavoriteStoryViewCell: UITableViewCell {
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyAuthorLabel: UILabel!
    @IBOutlet weak var storyDateLabel: UILabel!
    @IBOutlet weak var storyScoreLabel: UILabel!
    
    var story: Story? {
        didSet {
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
        storyTitleLabel.text = story?.title
        storyAuthorLabel.text = story?.author
        storyDateLabel.text = "asdf"
        storyScoreLabel.text = String(story?.score ?? 0)
    }
}
