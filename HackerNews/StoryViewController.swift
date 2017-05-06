//
//  StoryViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/4/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
  @IBOutlet weak var storyTitleLabel: UILabel!
  @IBOutlet weak var storyAuthorLabel: UILabel!
  @IBOutlet weak var storyScoreLabel: UILabel!
  @IBOutlet weak var storyWebView: UIWebView!
  
  private var _hackerStory: HackerNewsStory!
  
  var hackerStory: HackerNewsStory! {
    set {
      _hackerStory = newValue
    }
    get {
      return _hackerStory
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    storyTitleLabel.text = hackerStory.Title
    storyAuthorLabel.text = hackerStory.Author
    storyScoreLabel.text = "score \(hackerStory.Score)"
    
    if let url = hackerStory.Url {
      print("calling url: \(url.absoluteString)")
      storyWebView.loadRequest(URLRequest(url: url))
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
