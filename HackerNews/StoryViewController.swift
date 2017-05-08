//
//  StoryViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/4/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit
import WebKit

class StoryViewController: UIViewController, UITabBarControllerDelegate {
  @IBOutlet weak var storyTitleLabel: UILabel!
  @IBOutlet weak var storyAuthorLabel: UILabel!
  @IBOutlet weak var storyScoreLabel: UILabel!
  @IBOutlet weak var displayStoryView: UIView!
  
  private var wkViewConfiguration: WKWebViewConfiguration!
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
    tabBarController?.delegate = self
    
    wkViewConfiguration = WKWebViewConfiguration()
    wkViewConfiguration.ignoresViewportScaleLimits = true
    wkViewConfiguration.allowsInlineMediaPlayback = true
    
    storyTitleLabel.text = hackerStory.Title
    storyAuthorLabel.text = hackerStory.Author
    storyScoreLabel.text = "score \(hackerStory.Score)"
    
    if (hackerStory.Url != nil) {
      setupURLView()
      
    } else if (hackerStory.Text != nil) {
      setupTextView()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if let commentView = viewController as? CommentViewController {
      commentView.testLabel.text = "This is from me!!!!"
    }
  }
  
  private func setupURLView() {
    let webView = WKWebView(frame: view.frame, configuration: wkViewConfiguration)
    webView.load(URLRequest(url: hackerStory.Url!))
    
    displayStoryView.addSubview(webView)
  }
  
  private func setupTextView() {
    let textView = UITextView(frame: displayStoryView.frame)
    textView.text = hackerStory.Text
    
    displayStoryView.addSubview(textView)
  }
}
